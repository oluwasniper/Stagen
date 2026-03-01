import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import '../models/history_items.dart';

class HistoryService {
  static const String _boxName = 'history_items';
  late Box<HistoryItem> _box;

  Future<void> init() async {
    const secureStorage = FlutterSecureStorage();

    // Check if an encryption key exists in secure storage.
    var encryptionKeyString =
        await secureStorage.read(key: 'history_encryption_key');

    // If no key is found, generate a new one and store it securely.
    if (encryptionKeyString == null) {
      final key = Hive.generateSecureKey();
      await secureStorage.write(
        key: 'history_encryption_key',
        value: base64UrlEncode(key),
      );
      encryptionKeyString = base64UrlEncode(key);
    }

    final Uint8List encryptionKey = base64Url.decode(encryptionKeyString);

    // Register adapters if not already registered
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(HistoryItemTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(HistoryItemAdapter());
    }

    _box = await Hive.openBox<HistoryItem>(
      _boxName,
      encryptionCipher: HiveAesCipher(encryptionKey),
    );
  }

  Future<void> addItem(HistoryItem item) async {
    await _box.add(item);
  }

  List<HistoryItem> getAllItems() {
    return _box.values.toList();
  }

  Future<void> deleteItem(int index) async {
    await _box.deleteAt(index);
  }

  Future<void> clearAll() async {
    await _box.clear();
  }
}
