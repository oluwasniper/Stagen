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
      final initial = await _channel.invokeMethod<String>('getInitialText');
      if (initial != null && initial.trim().isNotEmpty) {
        _streamController.add(initial.trim());
      }
    } catch (_) {
      // Not supported on this platform/build or no incoming intent text.
    }
  }

  void dispose() {
    _streamController.close();
  }
}
