import 'dart:async';
import 'dart:developer' as dev;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';
import '../providers/qr_providers.dart';
import 'telemetry_service.dart';

final backgroundSyncServiceProvider = Provider<BackgroundSyncService>((ref) {
  final service = BackgroundSyncService(ref);
  ref.onDispose(() {
    unawaited(service.stop());
  });
  return service;
});

/// Periodically synchronizes local history with the backend while the app is
/// in foreground and online.
class BackgroundSyncService with WidgetsBindingObserver {
  BackgroundSyncService(this._ref);

  final Ref _ref;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  Timer? _periodicTimer;
  bool _isForeground = true;
  bool _isOnline = true;
  bool _syncInFlight = false;
  DateTime? _lastSyncAt;

  static const Duration _periodicInterval = Duration(minutes: 4);
  static const Duration _minSyncGap = Duration(seconds: 45);
  static const Duration _fetchTimeout = Duration(seconds: 15);

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
      var scannedSynced = false;
      var generatedSynced = false;
      Object? firstError;

      try {
        await _runCancelableFetch(
          notifier: _ref.read(scannedHistoryProvider.notifier),
          trigger: trigger,
          label: 'scanned',
        );
        scannedSynced = true;
      } catch (e, st) {
        firstError ??= e;
        dev.log(
          '[BackgroundSyncService] scanned sync failed ($trigger): $e',
          stackTrace: st,
          name: 'BackgroundSyncService',
        );
      }

      try {
        await _runCancelableFetch(
          notifier: _ref.read(generatedHistoryProvider.notifier),
          trigger: trigger,
          label: 'generated',
        );
        generatedSynced = true;
      } catch (e, st) {
        firstError ??= e;
        dev.log(
          '[BackgroundSyncService] generated sync failed ($trigger): $e',
          stackTrace: st,
          name: 'BackgroundSyncService',
        );
      }

      if (!scannedSynced || !generatedSynced) {
        _ref.read(telemetryServiceProvider).track(
          TelemetryEvents.backgroundSyncFailed,
          properties: {
            'trigger': trigger,
            'duration_ms': watch.elapsedMilliseconds,
            'error_type':
                firstError?.runtimeType.toString() ?? 'sync_partial_failure',
          },
        );
        return;
      }

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

  Future<void> _runCancelableFetch({
    required QRRecordListNotifier notifier,
    required String trigger,
    required String label,
  }) async {
    final cancellationToken = FetchCancellationToken();
    Timer? timeoutTimer;
    final timeoutCompleter = Completer<void>();
    final fetchFuture = notifier.fetchRecords(
      silent: true,
      cancellationToken: cancellationToken,
    );

    timeoutTimer = Timer(_fetchTimeout, () {
      cancellationToken.cancel();
      notifier.cancelInFlightFetch();
      if (timeoutCompleter.isCompleted) return;
      timeoutCompleter.completeError(
        TimeoutException(
          '[BackgroundSyncService] $label sync timed out ($trigger)',
          _fetchTimeout,
        ),
      );
    });

    try {
      await Future.any<void>([
        fetchFuture,
        timeoutCompleter.future,
      ]);
    } finally {
      timeoutTimer.cancel();
    }
  }
}
