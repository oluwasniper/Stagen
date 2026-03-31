// ignore_for_file: deprecated_member_use

import 'package:appwrite/appwrite.dart';

import '../models/qr_record.dart';

/// Service class for interacting with the Appwrite backend.
///
/// Handles CRUD operations for QR code records stored in
/// the Appwrite database.
///
/// **Prerequisites**: Create the database and collection in the Appwrite console:
/// 1. Database ID: `scagen_db`
/// 2. Collection ID: `qr_records`
/// 3. Attributes:
///    - `data` (string, size 4096, required)
///    - `type` (string, size 50, required) — 'scanned' or 'generated'
///    - `qrType` (string, size 50, required) — e.g. 'text', 'website', 'wifi'
///    - `label` (string, size 255, optional)
///    - `userId` (string, size 255, optional)
///    - `createdAt` (string, size 50, required)
/// 4. Set collection-level permissions: Users role → read, create, update, delete
/// Maximum number of records fetched per remote query.
/// Used both in [AppwriteService.getQRRecords] and in the prune guard in
/// [QRRecordListNotifier] to ensure the two thresholds stay in sync.
const kFetchLimit = 100;

class AppwriteService {
  static const String _databaseId = 'scagen_db';
  static const String _collectionId = 'qr_records';

  final Client _client;
  late final Databases _databases;

  AppwriteService({required Client client}) : _client = client {
    _databases = Databases(_client);
  }

  /// Save a QR record to the database.
  ///
  /// The [record] should already have [userId] set before calling this.
  Future<QRRecord> saveQRRecord(QRRecord record) async {
    final doc = await _databases.createDocument(
      databaseId: _databaseId,
      collectionId: _collectionId,
      documentId: ID.unique(),
      data: record.toJson(),
      permissions: record.userId != null
          ? [
              Permission.read(Role.user(record.userId!)),
              Permission.update(Role.user(record.userId!)),
              Permission.delete(Role.user(record.userId!)),
            ]
          : null,
    );
    return QRRecord.fromJson(doc.data);
  }

  /// Fetch all QR records for a specific user, optionally filtered by type.
  Future<List<QRRecord>> getQRRecords({
    String? type,
    String? userId,
  }) async {
    final queries = <String>[
      Query.orderDesc('createdAt'),
      Query.limit(kFetchLimit),
    ];
    if (type != null) {
      queries.add(Query.equal('type', type));
    }
    if (userId != null) {
      queries.add(Query.equal('userId', userId));
    }

    final result = await _databases.listDocuments(
      databaseId: _databaseId,
      collectionId: _collectionId,
      queries: queries,
    );

    return result.documents
        .map((doc) => QRRecord.fromJson({...doc.data, '\$id': doc.$id}))
        .toList();
  }

  /// Get a single QR record by ID.
  Future<QRRecord> getQRRecord(String id) async {
    final doc = await _databases.getDocument(
      databaseId: _databaseId,
      collectionId: _collectionId,
      documentId: id,
    );
    return QRRecord.fromJson({...doc.data, '\$id': doc.$id});
  }

  /// Delete a QR record by ID.
  Future<void> deleteQRRecord(String id) async {
    await _databases.deleteDocument(
      databaseId: _databaseId,
      collectionId: _collectionId,
      documentId: id,
    );
  }

  /// Delete all QR records belonging to [userId].
  ///
  /// Fetches in batches of [kFetchLimit] until no documents remain.
  Future<void> deleteAllUserData(String userId) async {
    await _deleteAllInCollection(
      collectionId: _collectionId,
      userId: userId,
    );
  }

  /// Delete all notification documents belonging to [userId].
  ///
  /// Called as part of account erasure so no PII lingers after deletion.
  Future<void> deleteAllUserNotifications(String userId) async {
    await _deleteAllInCollection(
      collectionId: 'notifications',
      userId: userId,
    );
  }

  /// Batch-deletes every document in [collectionId] where `userId == userId`.
  Future<void> _deleteAllInCollection({
    required String collectionId,
    required String userId,
  }) async {
    while (true) {
      final result = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: collectionId,
        queries: [
          Query.equal('userId', userId),
          Query.limit(kFetchLimit),
        ],
      );
      if (result.documents.isEmpty) break;
      for (final doc in result.documents) {
        await _databases.deleteDocument(
          databaseId: _databaseId,
          collectionId: collectionId,
          documentId: doc.$id,
        );
      }
    }
  }
}
