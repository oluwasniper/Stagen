import 'package:appwrite/appwrite.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_config.dart';
import '../models/qr_record.dart';
import '../services/appwrite_service.dart';
import '../services/offline_history_service.dart';
import 'auth_provider.dart';

// ─── Appwrite Client & Service Providers ───

final appwriteClientProvider = Provider<Client>((ref) {
  final configError = AppConfig.appwriteConfigError;
  if (configError != null) {
    throw StateError(
      '$configError '
      'Pass --dart-define-from-file=.env or explicit --dart-define flags.',
    );
  }
  if (AppConfig.appwriteProjectId.isEmpty) {
    throw StateError(
        'AppConfig.appwriteProjectId is not configured. '
        'Pass --dart-define=APPWRITE_PROJECT_ID=<value> at build time.');
  }
  final client = Client();
  client
      .setEndpoint(AppConfig.appwriteEndpoint)
      .setProject(AppConfig.appwriteProjectId);
  return client;
});

final appwriteServiceProvider = Provider<AppwriteService>((ref) {
  final client = ref.watch(appwriteClientProvider);
  return AppwriteService(client: client);
});

final offlineHistoryServiceProvider = Provider<OfflineHistoryService>((ref) {
  return OfflineHistoryService.instance;
});

// ─── History Providers ───

/// Holds the list of scanned QR records fetched from the backend.
final scannedHistoryProvider =
    StateNotifierProvider<QRRecordListNotifier, AsyncValue<List<QRRecord>>>(
        (ref) {
  final auth = ref.watch(authProvider);
  final userId = auth.user?.$id;
  return QRRecordListNotifier(
    ref.watch(offlineHistoryServiceProvider),
    ref.watch(appwriteServiceProvider),
    'scanned',
    userId: userId,
  );
});

/// Holds the list of generated QR records fetched from the backend.
final generatedHistoryProvider =
    StateNotifierProvider<QRRecordListNotifier, AsyncValue<List<QRRecord>>>(
        (ref) {
  final auth = ref.watch(authProvider);
  final userId = auth.user?.$id;
  return QRRecordListNotifier(
    ref.watch(offlineHistoryServiceProvider),
    ref.watch(appwriteServiceProvider),
    'generated',
    userId: userId,
  );
});

class QRRecordListNotifier extends StateNotifier<AsyncValue<List<QRRecord>>> {
  final OfflineHistoryService _offline;
  final AppwriteService _service;
  final String _type;
  final String? _userId;

  QRRecordListNotifier(
    this._offline,
    this._service,
    this._type, {
    String? userId,
  })
      : _userId = userId,
        super(const AsyncValue.loading()) {
    fetchRecords();
  }

  Future<void> fetchRecords() async {
    state = const AsyncValue.loading();
    try {
      // Local-first: always show encrypted offline cache.
      var records = _offline.getVisibleRecords(type: _type, userId: _userId);
      state = AsyncValue.data(records);

      // If authenticated, try syncing in background and refresh.
      if (_userId != null) {
        await _syncWithRemote();
        records = _offline.getVisibleRecords(type: _type, userId: _userId);
      }
      state = AsyncValue.data(records);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addRecord(QRRecord record) async {
    try {
      await _offline.addPendingCreate(record, userId: _userId);
      state = AsyncValue.data(
        _offline.getVisibleRecords(type: _type, userId: _userId),
      );
      unawaited(fetchRecords());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteRecord(String localId) async {
    try {
      await _offline.markPendingDelete(localId);
      state = AsyncValue.data(
        _offline.getVisibleRecords(type: _type, userId: _userId),
      );
      unawaited(fetchRecords());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> _syncWithRemote() async {
    final userId = _userId;
    if (userId == null) return;

    // Push pending creates
    final creates = await _offline.pendingCreates(type: _type, userId: userId);
    for (final local in creates) {
      try {
        final saved = await _service.saveQRRecord(
          QRRecord(
            data: local.data,
            type: local.type,
            qrType: local.qrType,
            label: local.label,
            userId: userId,
            createdAt: local.createdAt,
          ),
        );
        if (saved.id != null) {
          await _offline.markCreateSynced(
            localId: local.localId,
            remoteId: saved.id!,
          );
        }
      } catch (_) {
        // Offline/network errors are expected; keep pending for next sync.
      }
    }

    // Push pending deletes
    final deletes = await _offline.pendingDeletes(type: _type, userId: userId);
    for (final local in deletes) {
      try {
        if (local.remoteId != null) {
          await _service.deleteQRRecord(local.remoteId!);
        }
        await _offline.finalizeDelete(local.localId);
      } catch (_) {
        // Keep pending delete for next sync attempt.
      }
    }

    // Pull remote snapshot and merge into local store.
    try {
      final remoteRecords = await _service.getQRRecords(type: _type, userId: userId);
      final remoteIds = <String>{};
      for (final remote in remoteRecords) {
        if (remote.id != null) {
          remoteIds.add(remote.id!);
        }
        await _offline.upsertFromRemote(remote, userId: userId);
      }
      await _offline.pruneSyncedMissingFromRemote(
        type: _type,
        userId: userId,
        remoteIds: remoteIds,
      );
    } catch (_) {
      // Pull failed; keep local cache visible.
    }
  }
}

// ─── QR Generation State ───

/// Provider that holds the currently generated QR data string,
/// so the GeneratedQRScreen can display it.
final generatedQRDataProvider = StateProvider<String?>((ref) => null);

/// Provider that holds the QR option type label for the generated QR.
final generatedQRLabelProvider = StateProvider<String?>((ref) => null);

/// Provider that holds the QR option type name for the generated QR.
final generatedQRTypeProvider = StateProvider<String?>((ref) => null);

// ─── Scanned QR State ───

/// Provider that holds the last scanned QR data string.
final scannedQRDataProvider = StateProvider<String?>((ref) => null);
