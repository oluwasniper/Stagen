import 'dart:developer' as dev;

import 'package:flutter/services.dart';

import '../utils/app_router.dart';
import '../utils/route/app_path.dart';
import 'telemetry_service.dart';

/// Push notification bridge.
///
/// Uses a method channel so native implementations can evolve independently.
/// When native wiring is absent, this service becomes a safe no-op.
class PushNotificationService {
  PushNotificationService({
    required TelemetryService Function() telemetryReader,
  }) : _telemetryReader = telemetryReader;

  final TelemetryService Function() _telemetryReader;

  static const MethodChannel _channel =
      MethodChannel('scagen/push_notifications');

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    _channel.setMethodCallHandler(_onMethodCall);

    try {
      final granted = await _channel.invokeMethod<bool>('initialize') ?? false;
      _telemetryReader().track(
        TelemetryEvents.pushRegistrationAttempted,
        properties: {'granted': granted},
      );
    } on MissingPluginException {
      dev.log(
        '[PushNotificationService] native push channel not implemented yet.',
        name: 'PushNotificationService',
      );
    } on PlatformException catch (e, st) {
      dev.log(
        '[PushNotificationService] initialize failed: $e',
        stackTrace: st,
        name: 'PushNotificationService',
      );
      _telemetryReader().track(
        TelemetryEvents.pushRegistrationFailed,
        properties: {'code': e.code},
      );
    }
  }

  Future<void> _onMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onNotificationReceived':
        final payload = _asMap(call.arguments);
        _telemetryReader().track(
          TelemetryEvents.pushNotificationReceived,
          properties: {
            'campaign': payload['campaign']?.toString() ?? 'unknown',
            'target': payload['target']?.toString() ?? 'unknown',
          },
        );
        break;

      case 'onNotificationOpened':
        final payload = _asMap(call.arguments);
        _telemetryReader().track(
          TelemetryEvents.pushNotificationOpened,
          properties: {
            'campaign': payload['campaign']?.toString() ?? 'unknown',
            'target': payload['target']?.toString() ?? 'unknown',
          },
        );
        _handleOpenedNotification(payload);
        break;
    }
  }

  void _handleOpenedNotification(Map<String, Object?> payload) {
    final target = payload['target']?.toString();
    switch (target) {
      case 'scan':
        AppGoRouter.router.go(AppPath.home);
        break;
      case 'generate':
        AppGoRouter.router.go(AppPath.generateHome);
        break;
      case 'history':
        AppGoRouter.router.go(AppPath.history);
        break;
      default:
        // Keep current screen when payload target is unknown.
        break;
    }
  }

  Map<String, Object?> _asMap(dynamic value) {
    if (value is! Map) return const <String, Object?>{};
    return {
      for (final entry in value.entries) entry.key.toString(): entry.value,
    };
  }
}
