import 'dart:async';

import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/qr_record.dart';
import '../services/appwrite_service.dart';
import '../services/appwrite_client.dart';
import '../services/offline_history_service.dart';
import 'auth_provider.dart';

// ─── Appwrite Client & Service Providers ───

final appwriteClientProvider = Provider<Client>((ref) {
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
  int _fetchGeneration = 0;

  QRRecordListNotifier(
    this._offline,
    this._service,
    this._type, {
    String? userId,
  })  : _userId = userId,
        super(const AsyncValue.loading()) {
    fetchRecords();
  }

  void _setDataState() {
    if (!mounted) return;
    state = AsyncValue.data(
      _offline.getVisibleRecords(type: _type, userId: _userId),
    );
  }

  Future<void> fetchRecords({
    bool silent = false,
    FetchCancellationToken? cancellationToken,
  }) async {
    final fetchId = ++_fetchGeneration;
    if (_shouldAbortFetch(fetchId, cancellationToken)) return;
    if (!silent || !state.hasValue) {
      state = const AsyncValue.loading();
    }
    try {
      // Local-first: always show encrypted offline cache.
      var records = _offline.getVisibleRecords(type: _type, userId: _userId);
      if (_shouldAbortFetch(fetchId, cancellationToken)) return;
      state = AsyncValue.data(records);

      // If authenticated, try syncing in background and refresh.
      if (_userId != null) {
        await _syncWithRemote(
          shouldAbort: () => _shouldAbortFetch(fetchId, cancellationToken),
        );
        if (_shouldAbortFetch(fetchId, cancellationToken)) return;
        records = _offline.getVisibleRecords(type: _type, userId: _userId);
      }
      if (_shouldAbortFetch(fetchId, cancellationToken)) return;
      state = AsyncValue.data(records);
    } catch (e, st) {
      if (_shouldAbortFetch(fetchId, cancellationToken)) return;
      state = AsyncValue.error(e, st);
    }
  }

  void cancelInFlightFetch() {
    _fetchGeneration++;
  }

  bool _shouldAbortFetch(
    int fetchId,
    FetchCancellationToken? cancellationToken,
  ) {
    return !mounted ||
        fetchId != _fetchGeneration ||
        (cancellationToken?.isCancelled ?? false);
  }

  Future<void> addRecord(QRRecord record) async {
    if (!mounted) return;
    try {
      await _offline.addPendingCreate(record, userId: _userId);
      if (!mounted) return;
      if (_userId != null) {
        await _syncWithRemote();
        if (!mounted) return;
      }
      _setDataState();
    } catch (_) {
      // Show whatever is locally cached even on error.
      _setDataState();
    }
  }

  Future<bool> deleteRecord(String localId) async {
    if (!mounted) return false;
    try {
      await _offline.markPendingDelete(localId);
      if (!mounted) return false;
      _setDataState();
      if (_userId == null) {
        return true;
      }
      try {
        await _syncWithRemote();
        if (!mounted) return true;
        _setDataState();
      } catch (e, st) {
        if (!mounted) return true;
        state = AsyncValue.error(e, st);
      }
      return true;
    } catch (e, st) {
      if (!mounted) return false;
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<void> _syncWithRemote({bool Function()? shouldAbort}) async {
    if (!mounted || (shouldAbort?.call() ?? false)) return;
    final userId = _userId;
    if (userId == null) return;

    // Push pending creates
    final creates = await _offline.pendingCreates(type: _type, userId: userId);
    if (!mounted || (shouldAbort?.call() ?? false)) return;
    for (final local in creates) {
      if (!mounted || (shouldAbort?.call() ?? false)) return;
      // Re-check that the entry is still pending before pushing remotely.
      // A concurrent delete can remove it from the pending list between the
      // snapshot above and this iteration, which would create a ghost record.
      final stillPending = await _offline.isPendingCreate(local.localId);
      if (!mounted || (shouldAbort?.call() ?? false)) return;
      if (!stillPending) continue;
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
          // Only mark synced if the entry is still present locally.
          if (await _offline.isPendingCreate(local.localId)) {
            await _offline.markCreateSynced(
              localId: local.localId,
              remoteId: saved.id!,
            );
          }
        }
      } catch (_) {
        // Offline/network errors are expected; keep pending for next sync.
      }
    }

    // Push pending deletes
    final deletes = await _offline.pendingDeletes(type: _type, userId: userId);
    if (!mounted || (shouldAbort?.call() ?? false)) return;
    for (final local in deletes) {
      if (!mounted || (shouldAbort?.call() ?? false)) return;
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
      final remoteRecords =
          await _service.getQRRecords(type: _type, userId: userId);
      if (!mounted || (shouldAbort?.call() ?? false)) return;
      await _offline.upsertAllFromRemote(remoteRecords, userId: userId);
      if (!mounted || (shouldAbort?.call() ?? false)) return;
      final remoteIds = {
        for (final r in remoteRecords)
          if (r.id != null) r.id!,
      };
      // Only prune when we have a full remote snapshot. If the result set hit
      // the server page limit (kFetchLimit), there may be more records we
      // haven't seen, so skip pruning to avoid deleting valid local records.
      if (remoteRecords.length < kFetchLimit) {
        await _offline.pruneSyncedMissingFromRemote(
          type: _type,
          userId: userId,
          remoteIds: remoteIds,
        );
        if (!mounted || (shouldAbort?.call() ?? false)) return;
      }
    } catch (_) {
      // Pull failed; keep local cache visible.
    }
  }
}

class FetchCancellationToken {
  bool _isCancelled = false;

  bool get isCancelled => _isCancelled;

  void cancel() {
    _isCancelled = true;
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
