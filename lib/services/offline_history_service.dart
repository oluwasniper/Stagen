import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';

import '../models/local_qr_record.dart';
import '../models/qr_record.dart';

class OfflineHistoryService {
  OfflineHistoryService._();

  static final OfflineHistoryService instance = OfflineHistoryService._();

  static const String _boxName = 'offline_qr_history_v1';
  static const String _encryptionKeyName = 'offline_qr_history_key';

  late Box<LocalQRRecord> _box;

  Future<void> init() async {
    const secureStorage = FlutterSecureStorage();
    var encryptionKeyString =
        await secureStorage.read(key: _encryptionKeyName);

    if (encryptionKeyString == null) {
      final key = Hive.generateSecureKey();
      encryptionKeyString = base64UrlEncode(key);
      await secureStorage.write(
        key: _encryptionKeyName,
        value: encryptionKeyString,
      );
    }

    final Uint8List encryptionKey = base64Url.decode(encryptionKeyString);

    if (!Hive.isAdapterRegistered(17)) {
      Hive.registerAdapter(LocalQRRecordAdapter());
    }

    _box = await Hive.openBox<LocalQRRecord>(
      _boxName,
      encryptionCipher: HiveAesCipher(encryptionKey),
    );
  }

  Future<LocalQRRecord> addPendingCreate(QRRecord record, {String? userId}) async {
    final local = LocalQRRecord(
      localId: _newLocalId(),
      remoteId: null,
      data: record.data,
      type: record.type,
      qrType: record.qrType,
      label: record.label,
      userId: userId ?? record.userId,
      createdAt: record.createdAt,
      pendingCreate: true,
      pendingDelete: false,
    );
    await _box.put(local.localId, local);
    return local;
  }

  List<QRRecord> getVisibleRecords({
    required String type,
    required String? userId,
  }) {
    final records = _box.values
        .where(
          (r) =>
              r.type == type &&
              r.userId == userId &&
              !r.pendingDelete,
        )
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return records.map((r) => r.toDisplayRecord()).toList();
  }

  Future<void> markPendingDelete(String localId) async {
    final record = _box.get(localId);
    if (record == null) return;

    // Never synced: remove permanently.
    if (record.pendingCreate && record.remoteId == null) {
      await _box.delete(localId);
      return;
    }

    await _box.put(
      localId,
      record.copyWith(
        pendingCreate: false,
        pendingDelete: true,
      ),
    );
  }

  Future<List<LocalQRRecord>> pendingCreates({
    required String type,
    required String userId,
  }) async {
    return _box.values
        .where(
          (r) =>
              r.type == type &&
              r.userId == userId &&
              r.pendingCreate &&
              !r.pendingDelete,
        )
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  Future<List<LocalQRRecord>> pendingDeletes({
    required String type,
    required String userId,
  }) async {
    return _box.values
        .where(
          (r) =>
              r.type == type &&
              r.userId == userId &&
              r.pendingDelete,
        )
        .toList();
  }

  Future<bool> isPendingCreate(String localId) async {
    final record = _box.get(localId);
    return record != null && record.pendingCreate && !record.pendingDelete;
  }

  Future<void> markCreateSynced({
    required String localId,
    required String remoteId,
  }) async {
    final record = _box.get(localId);
    if (record == null) return;
    await _box.put(
      localId,
      record.copyWith(
        remoteId: remoteId,
        pendingCreate: false,
        pendingDelete: false,
      ),
    );
  }

  Future<void> finalizeDelete(String localId) async {
    await _box.delete(localId);
  }

  Future<void> upsertFromRemote(QRRecord remote, {required String userId}) async {
    final existing = _box.values.where((r) => r.remoteId == remote.id).toList();
    if (existing.isNotEmpty) {
      final current = existing.first;
      if (!current.pendingCreate && !current.pendingDelete) {
        await _box.put(
          current.localId,
          current.copyWith(
            data: remote.data,
            type: remote.type,
            qrType: remote.qrType,
            label: remote.label,
            userId: remote.userId ?? userId,
            createdAt: remote.createdAt,
          ),
        );
      }
      return;
    }

    final local = LocalQRRecord(
      localId: _newLocalId(),
      remoteId: remote.id,
      data: remote.data,
      type: remote.type,
      qrType: remote.qrType,
      label: remote.label,
      userId: remote.userId ?? userId,
      createdAt: remote.createdAt,
      pendingCreate: false,
      pendingDelete: false,
    );
    await _box.put(local.localId, local);
  }

  /// Upserts a batch of remote records using a single O(n) index scan rather
  /// than an O(n²) per-record search.
  Future<void> upsertAllFromRemote(
    List<QRRecord> remotes, {
    required String userId,
  }) async {
    final remoteIdIndex = <String, LocalQRRecord>{
      for (final r in _box.values)
        if (r.remoteId != null) r.remoteId!: r,
    };

    for (final remote in remotes) {
      final current = remote.id != null ? remoteIdIndex[remote.id] : null;
      if (current != null) {
        if (!current.pendingCreate && !current.pendingDelete) {
          await _box.put(
            current.localId,
            current.copyWith(
              data: remote.data,
              type: remote.type,
              qrType: remote.qrType,
              label: remote.label,
              userId: remote.userId ?? userId,
              createdAt: remote.createdAt,
            ),
          );
        }
      } else {
        final local = LocalQRRecord(
          localId: _newLocalId(),
          remoteId: remote.id,
          data: remote.data,
          type: remote.type,
          qrType: remote.qrType,
          label: remote.label,
          userId: remote.userId ?? userId,
          createdAt: remote.createdAt,
          pendingCreate: false,
          pendingDelete: false,
        );
        await _box.put(local.localId, local);
      }
    }
  }

  Future<void> pruneSyncedMissingFromRemote({
    required String type,
    required String userId,
    required Set<String> remoteIds,
  }) async {
    final toDelete = _box.values.where((r) {
      return r.type == type &&
          r.userId == userId &&
          r.remoteId != null &&
          !r.pendingCreate &&
          !r.pendingDelete &&
          !remoteIds.contains(r.remoteId);
    }).toList();

    for (final r in toDelete) {
      await _box.delete(r.localId);
    }
  }

  LocalQRRecord? getByLocalId(String localId) => _box.get(localId);

  String _newLocalId() {
    final ts = DateTime.now().microsecondsSinceEpoch;
    final rand = Random.secure().nextInt(1 << 32).toRadixString(16);
    return 'local_$ts$rand';
  }
}
