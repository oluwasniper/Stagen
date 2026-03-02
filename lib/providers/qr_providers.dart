import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_config.dart';
import '../models/qr_record.dart';
import '../services/appwrite_service.dart';
import 'auth_provider.dart';

// ─── Appwrite Client & Service Providers ───

final appwriteClientProvider = Provider<Client>((ref) {
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

// ─── History Providers ───

/// Holds the list of scanned QR records fetched from the backend.
final scannedHistoryProvider =
    StateNotifierProvider<QRRecordListNotifier, AsyncValue<List<QRRecord>>>(
        (ref) {
  final auth = ref.watch(authProvider);
  final userId = auth.user?.$id;
  return QRRecordListNotifier(
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
    ref.watch(appwriteServiceProvider),
    'generated',
    userId: userId,
  );
});

class QRRecordListNotifier extends StateNotifier<AsyncValue<List<QRRecord>>> {
  final AppwriteService _service;
  final String _type;
  final String? _userId;

  QRRecordListNotifier(this._service, this._type, {String? userId})
      : _userId = userId,
        super(const AsyncValue.loading()) {
    fetchRecords();
  }

  Future<void> fetchRecords() async {
    state = const AsyncValue.loading();
    try {
      final records = await _service.getQRRecords(type: _type, userId: _userId);
      state = AsyncValue.data(records);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addRecord(QRRecord record) async {
    try {
      // Ensure the record carries the current userId
      final toSave =
          _userId != null ? record.copyWith(userId: _userId) : record;
      final saved = await _service.saveQRRecord(toSave);
      final current = state.valueOrNull ?? [];
      state = AsyncValue.data([saved, ...current]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteRecord(String id) async {
    try {
      await _service.deleteQRRecord(id);
      final current = state.valueOrNull ?? [];
      state = AsyncValue.data(current.where((r) => r.id != id).toList());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
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
