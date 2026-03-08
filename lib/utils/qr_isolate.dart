import 'dart:async';
import 'dart:isolate';

/// Runs QR data classification + any heavy string parsing in a background
/// isolate so the main thread stays at 60/120 fps during scan detection.
///
/// Usage:
/// ```dart
/// final result = await QRIsolate.classify(rawData);
/// ```
abstract final class QRIsolate {
  static const _requestTimeout = Duration(seconds: 2);

  static Isolate? _workerIsolate;
  static ReceivePort? _receivePort;
  static SendPort? _workerSendPort;
  static Completer<void>? _startupCompleter;
  static int _nextRequestId = 0;
  static final Map<int, Completer<QRClassification>> _pendingRequests = {};

  /// Starts the worker isolate ahead of time, so the first scan has no spawn
  /// latency on the UI thread.
  static Future<void> prewarm() async {
    await _ensureWorkerStarted();
  }

  /// Classifies raw QR data off the main thread and returns a [QRClassification].
  ///
  /// If isolate infrastructure fails for any reason, falls back to local
  /// classification to avoid breaking the user flow.
  static Future<QRClassification> classify(String data) async {
    try {
      await _ensureWorkerStarted();
      final port = _workerSendPort;
      if (port == null) {
        return _classifyInIsolate(data);
      }

      final id = _nextRequestId++;
      final completer = Completer<QRClassification>();
      _pendingRequests[id] = completer;
      port.send({'id': id, 'data': data});

      return completer.future.timeout(
        _requestTimeout,
        onTimeout: () {
          _pendingRequests.remove(id);
          return _classifyInIsolate(data);
        },
      );
    } catch (_) {
      return _classifyInIsolate(data);
    }
  }

  static Future<void> dispose() async {
    _workerIsolate?.kill(priority: Isolate.immediate);
    _workerIsolate = null;
    _workerSendPort = null;
    _receivePort?.close();
    _receivePort = null;
    _startupCompleter = null;

    final pending = _pendingRequests.values.toList(growable: false);
    _pendingRequests.clear();
    for (final completer in pending) {
      if (!completer.isCompleted) {
        completer.completeError(
          StateError('QR worker isolate disposed before completion'),
        );
      }
    }
  }

  static Future<void> _ensureWorkerStarted() async {
    if (_workerSendPort != null) return;
    final currentCompleter = _startupCompleter;
    if (currentCompleter != null) {
      return currentCompleter.future;
    }

    final completer = Completer<void>();
    _startupCompleter = completer;

    try {
      final receivePort = ReceivePort();
      _receivePort = receivePort;

      receivePort.listen((message) {
        if (message is SendPort) {
          _workerSendPort ??= message;
          if (!completer.isCompleted) {
            completer.complete();
          }
          return;
        }

        if (message is! Map) return;
        final id = message['id'];
        if (id is! int) return;
        final requestCompleter = _pendingRequests.remove(id);
        if (requestCompleter == null || requestCompleter.isCompleted) return;
        requestCompleter.complete(_classificationFromMap(message));
      });

      _workerIsolate = await Isolate.spawn<SendPort>(
        _workerMain,
        receivePort.sendPort,
      );

      await completer.future.timeout(_requestTimeout);
    } catch (_) {
      if (!completer.isCompleted) {
        completer.complete();
      }
      await dispose();
    } finally {
      _startupCompleter = null;
    }
  }

  static void _workerMain(SendPort mainPort) {
    final workerPort = ReceivePort();
    mainPort.send(workerPort.sendPort);

    workerPort.listen((message) {
      if (message is! Map) return;
      final id = message['id'];
      final raw = message['data'];
      if (id is! int || raw is! String) return;

      final result = _classifyInIsolate(raw);
      mainPort.send({
        'id': id,
        'type': result.type.index,
        'displayData': result.displayData,
      });
    });
  }

  static QRClassification _classificationFromMap(Map<dynamic, dynamic> map) {
    final typeIndex = map['type'] as int? ?? QRDataType.text.index;
    final normalizedIndex = typeIndex.clamp(0, QRDataType.values.length - 1);
    final type = QRDataType.values[normalizedIndex];
    return QRClassification(
      type: type,
      displayData: map['displayData']?.toString() ?? '',
    );
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
