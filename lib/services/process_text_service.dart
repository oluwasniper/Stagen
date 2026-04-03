import 'dart:async';

import 'package:flutter/services.dart';

// Matches the classifier's internal _kMaxInputCodeUnits ceiling so oversized
// payloads are dropped at the channel boundary — before any regex work runs.
const int _kMaxProcessTextLength = 8192;

class ExternalProcessTextService {
  ExternalProcessTextService._();

  static final ExternalProcessTextService instance =
      ExternalProcessTextService._();
  static const MethodChannel _channel = MethodChannel('scagen/process_text');

  final StreamController<String> _streamController =
      StreamController<String>.broadcast();
  bool _initialized = false;

  Stream<String> get textStream => _streamController.stream;

  /// Trims and gates a raw native string. Returns null for empty or oversized
  /// values so they are silently dropped before reaching the classifier.
  String? _sanitize(String? raw) {
    if (raw == null) return null;
    final trimmed = raw.trim();
    if (trimmed.isEmpty || trimmed.length > _kMaxProcessTextLength) return null;
    return trimmed;
  }

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onText') {
        final text = _sanitize(call.arguments as String?);
        if (text != null) _streamController.add(text);
      }
    });

    try {
      final initialTexts =
          await _channel.invokeMethod<dynamic>('getInitialText');
      if (initialTexts is String) {
        final text = _sanitize(initialTexts);
        if (text != null) _streamController.add(text);
      } else if (initialTexts is List) {
        for (final text in initialTexts.whereType<String>()) {
          final sanitized = _sanitize(text);
          if (sanitized != null) _streamController.add(sanitized);
        }
      }
    } on MissingPluginException {
      // Not supported on this platform/build or no incoming intent text.
    } on PlatformException {
      // Not supported on this platform/build or no incoming intent text.
    }
  }

  void dispose() {
    _streamController.close();
  }
}
