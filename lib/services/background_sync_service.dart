import 'dart:async';
import 'dart:developer' as dev;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';
import '../providers/qr_providers.dart';
import 'telemetry_service.dart';

/// Periodically synchronizes local history with the backend while the app is
/// in foreground and online.
class BackgroundSyncService with WidgetsBindingObserver {
  BackgroundSyncService(this._ref);

  final WidgetRef _ref;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  Timer? _periodicTimer;
  bool _isForeground = true;
  bool _isOnline = true;
  bool _syncInFlight = false;
  DateTime? _lastSyncAt;

  static const Duration _periodicInterval = Duration(minutes: 4);
  static const Duration _minSyncGap = Duration(seconds: 45);

  void start() {
    WidgetsBinding.instance.addObserver(this);
    _periodicTimer = Timer.periodic(
      _periodicInterval,
      (_) => unawaited(_sync(trigger: 'periodic')),
    );

    _connectivitySub =
        Connectivity().onConnectivityChanged.listen(_onConnectivityChanged);
    unawaited(_bootstrapConnectivityAndSync());
  }

  Future<void> stop() async {
    WidgetsBinding.instance.removeObserver(this);
    _periodicTimer?.cancel();
    await _connectivitySub?.cancel();
  }

  Future<void> _bootstrapConnectivityAndSync() async {
    try {
      final connectivity = await Connectivity().checkConnectivity();
      _isOnline = _hasConnection(connectivity);
      if (_isOnline) {
        await _sync(trigger: 'startup');
      }
    } catch (e, st) {
      dev.log(
        '[BackgroundSyncService] connectivity bootstrap failed: $e',
        stackTrace: st,
        name: 'BackgroundSyncService',
      );
    }
  }

  void _onConnectivityChanged(List<ConnectivityResult> results) {
    final nowOnline = _hasConnection(results);
    final becameOnline = !_isOnline && nowOnline;
    _isOnline = nowOnline;

    if (becameOnline) {
      unawaited(_sync(trigger: 'connectivity_regained'));
    }
  }

  bool _hasConnection(List<ConnectivityResult> results) {
    return results.any((result) => result != ConnectivityResult.none);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _isForeground = true;
        unawaited(_sync(trigger: 'app_resumed'));
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _isForeground = false;
        break;
    }
  }

  Future<void> _sync({required String trigger}) async {
    if (_syncInFlight || !_isForeground || !_isOnline) return;

    final auth = _ref.read(authProvider);
    if (!auth.isAuthenticated) return;

    final now = DateTime.now();
    if (_lastSyncAt != null && now.difference(_lastSyncAt!) < _minSyncGap) {
      return;
    }

    _syncInFlight = true;
    final watch = Stopwatch()..start();

    try {
      await Future.wait([
        _ref.read(scannedHistoryProvider.notifier).fetchRecords(silent: true),
        _ref.read(generatedHistoryProvider.notifier).fetchRecords(silent: true),
      ]).timeout(const Duration(seconds: 15));
      _lastSyncAt = DateTime.now();
      _ref.read(telemetryServiceProvider).track(
        TelemetryEvents.backgroundSyncCompleted,
        properties: {
          'trigger': trigger,
          'duration_ms': watch.elapsedMilliseconds,
        },
      );
    } catch (e, st) {
      dev.log(
        '[BackgroundSyncService] sync failed ($trigger): $e',
        stackTrace: st,
        name: 'BackgroundSyncService',
      );
      _ref.read(telemetryServiceProvider).track(
        TelemetryEvents.backgroundSyncFailed,
        properties: {
          'trigger': trigger,
          'duration_ms': watch.elapsedMilliseconds,
          'error_type': e.runtimeType.toString(),
        },
      );
    } finally {
      _syncInFlight = false;
    }
  }
}
