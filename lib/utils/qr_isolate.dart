import 'dart:isolate';

/// Runs QR data classification + any heavy string parsing in a background
/// isolate so the main thread stays at 60/120 fps during scan detection.
///
/// Usage:
/// ```dart
/// final result = await QRIsolate.classify(rawData);
/// ```
abstract final class QRIsolate {
  /// Classifies raw QR data off the main thread and returns a [QRClassification].
  static Future<QRClassification> classify(String data) async {
    final result = await Isolate.run(() => _classifyInIsolate(data));
    return result;
  }

  static QRClassification _classifyInIsolate(String data) {
    final lower = data.toLowerCase().trimLeft();

    if (lower.startsWith('http://') || lower.startsWith('https://')) {
      return QRClassification(type: QRDataType.url, displayData: data);
    }
    if (lower.startsWith('mailto:')) {
      return QRClassification(
        type: QRDataType.email,
        displayData: data.substring(7),
      );
    }
    if (lower.startsWith('tel:')) {
      return QRClassification(
        type: QRDataType.phone,
        displayData: data.substring(4),
      );
    }
    if (lower.startsWith('wifi:')) {
      return QRClassification(
        type: QRDataType.wifi,
        displayData: _parseWifiSsid(data) ?? data,
      );
    }
    if (lower.startsWith('begin:vcard')) {
      return QRClassification(
        type: QRDataType.contact,
        displayData: _parseVCardName(data) ?? data,
      );
    }
    if (lower.startsWith('begin:vevent')) {
      return QRClassification(
        type: QRDataType.event,
        displayData: _parseVEventSummary(data) ?? data,
      );
    }
    if (lower.startsWith('geo:')) {
      return QRClassification(
        type: QRDataType.location,
        displayData: data.substring(4),
      );
    }
    // Phone number heuristic
    final stripped = data.replaceAll(RegExp(r'[\s\-().+]'), '');
    if (stripped.length >= 7 &&
        stripped.length <= 15 &&
        RegExp(r'^\d+$').hasMatch(stripped)) {
      return QRClassification(type: QRDataType.phone, displayData: data);
    }
    return QRClassification(type: QRDataType.text, displayData: data);
  }

  static String? _parseWifiSsid(String data) {
    final match = RegExp(r'S:([^;]+)').firstMatch(data);
    return match?.group(1);
  }

  static String? _parseVCardName(String data) {
    final match = RegExp(r'FN:(.+)', caseSensitive: false).firstMatch(data);
    return match?.group(1)?.trim();
  }

  static String? _parseVEventSummary(String data) {
    final match =
        RegExp(r'SUMMARY:(.+)', caseSensitive: false).firstMatch(data);
    return match?.group(1)?.trim();
  }
}

enum QRDataType { url, email, phone, wifi, contact, event, location, text }

class QRClassification {
  final QRDataType type;

  /// Human-friendly string to display (stripped of scheme prefix where appropriate).
  final String displayData;

  const QRClassification({required this.type, required this.displayData});

  /// Maps to the qrType string used in [QRRecord].
  String get qrTypeString => switch (type) {
        QRDataType.url => 'url',
        QRDataType.email => 'email',
        QRDataType.phone => 'phone',
        QRDataType.wifi => 'wifi',
        QRDataType.contact => 'contact',
        QRDataType.event => 'event',
        QRDataType.location => 'location',
        QRDataType.text => 'text',
      };
}
