import 'dart:async';

import 'package:flutter/services.dart';

class ExternalProcessTextService {
  ExternalProcessTextService._();

  static final ExternalProcessTextService instance =
      ExternalProcessTextService._();
  static const MethodChannel _channel = MethodChannel('scagen/process_text');

  final StreamController<String> _streamController =
      StreamController<String>.broadcast();
  bool _initialized = false;

  Stream<String> get textStream => _streamController.stream;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onText') {
        final text = call.arguments as String?;
        if (text != null && text.trim().isNotEmpty) {
          _streamController.add(text.trim());
        }
      }
    });

    try {
      final initialTexts =
          await _channel.invokeMethod<dynamic>('getInitialText');
      if (initialTexts is String) {
        final text = initialTexts.trim();
        if (text.isNotEmpty) {
          _streamController.add(text);
        }
      } else if (initialTexts is List) {
        for (final text in initialTexts.whereType<String>()) {
          final trimmed = text.trim();
          if (trimmed.isNotEmpty) {
            _streamController.add(trimmed);
          }
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
