import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// to use he l10n, you nee to import the generated file
import 'l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scagen/utils/app_theme.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:scagen/services/app_performance_service.dart';
import 'package:scagen/services/background_sync_service.dart';
import 'package:scagen/services/telemetry_service.dart';
import 'package:scagen/services/offline_history_service.dart';
import 'package:scagen/services/appwrite_messaging_service.dart';
import 'package:scagen/services/push_notification_service.dart';
import 'package:scagen/services/process_text_service.dart';
import 'package:scagen/utils/external_text_classifier.dart';
import 'package:scagen/utils/qr_isolate.dart';

import 'l10n/l10n.dart';
import 'providers/auth_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/qr_providers.dart';
import 'providers/settings_provider.dart';
import 'utils/app_router.dart';
import 'utils/route/app_path.dart';
import 'widgets/notification_overlay.dart';

final DateTime _appLaunchStartedAt = DateTime.now();

Future<void> main() async {
  final bootstrap = runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      FlutterError.onError = (details) {
        FlutterError.presentError(details);
        Zone.current.handleUncaughtError(
          details.exception,
          details.stack ?? StackTrace.current,
        );
      };
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
      await Future.wait([
        initPostHog(),
        Hive.initFlutter(),
      ]);
      await OfflineHistoryService.instance.init();
      runApp(
        const ProviderScope(
          child: MyApp(),
        ),
      );
    },
    (error, stackTrace) {
      log('[main] uncaught zone error: $error', stackTrace: stackTrace);
    },
  );
  if (bootstrap != null) {
    await bootstrap;
  }
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  final ShorebirdUpdater updater = ShorebirdUpdater();
  late final AppPerformanceService _performanceService;
  late final BackgroundSyncService _backgroundSyncService;
  late final PushNotificationService _pushNotificationService;
  late final AppwriteMessagingService _messagingService;
  StreamSubscription<String>? _processTextSub;
  String? _activeRoute;
  DateTime? _activeRouteEnteredAt;
  bool _errorHandlersBound = false;

  @override
  void initState() {
    super.initState();
    _bindGlobalErrorHandlers();
    _initRuntimeServices();
    _initRouteTelemetry();
    _trackStartupAfterFirstFrame();

    updater.readCurrentPatch().then((currentPatch) {
      log('The current patch number is: ${currentPatch?.number}');
    });
    if (kReleaseMode) {
      unawaited(_checkForUpdates());
    }
    unawaited(QRIsolate.prewarm());
    unawaited(_initPushNotifications());
    unawaited(_initExternalProcessText());
  }

  void _initRuntimeServices() {
    _performanceService = AppPerformanceService(
      telemetryReader: () => ref.read(telemetryServiceProvider),
    )..start();

    _backgroundSyncService = ref.read(backgroundSyncServiceProvider)..start();

    _pushNotificationService = PushNotificationService(
      telemetryReader: () => ref.read(telemetryServiceProvider),
    );

    _messagingService = AppwriteMessagingService(
      client: ref.read(appwriteClientProvider),
      telemetryReader: () => ref.read(telemetryServiceProvider),
    );

    // Eagerly initialise the notification inbox provider so it starts
    // listening to InAppNotificationService before any notifications arrive.
    ref.read(notificationProvider.notifier);

    // Subscribe Realtime notifications for any already-authenticated user
    // (e.g. session resumed on cold start).
    final authState = ref.read(authProvider);
    if (authState.isAuthenticated && authState.user != null) {
      final userId = authState.user!.$id;
      _messagingService.subscribeToUserNotifications(userId);
      unawaited(_messagingService.loadExistingNotifications(userId));
    }

    // React to future sign-in / sign-out events.
    ref.listenManual(authProvider, (previous, next) {
      if (next.isAuthenticated && next.user != null) {
        final userId = next.user!.$id;
        _messagingService.subscribeToUserNotifications(userId);
        unawaited(_messagingService.loadExistingNotifications(userId));
      } else if (!(next.isAuthenticated)) {
        _messagingService.unsubscribe();
      }
    });
  }

  void _bindGlobalErrorHandlers() {
    if (_errorHandlersBound) return;
    _errorHandlersBound = true;

    final previousFlutterErrorHandler = FlutterError.onError;
    FlutterError.onError = (details) {
      previousFlutterErrorHandler?.call(details);
      _reportException(
        details.exception,
        details.stack ?? StackTrace.current,
        source: 'flutter_error',
        fatal: true,
      );
    };

    PlatformDispatcher.instance.onError = (error, stackTrace) {
      _reportException(
        error,
        stackTrace,
        source: 'platform_dispatcher',
        fatal: true,
      );
      return false;
    };
  }

  Future<void> _initPushNotifications() async {
    try {
      await _pushNotificationService.initialize();
    } catch (e, st) {
      log('[MyApp] push notifications init failed: $e', stackTrace: st);
    }
  }

  void _initRouteTelemetry() {
    AppGoRouter.router.routerDelegate.addListener(_onRouteChanged);
    _onRouteChanged();
  }

  void _onRouteChanged() {
    if (!mounted) return;
    final now = DateTime.now();
    final currentRoute = _routerLocation();
    if (_activeRoute == currentRoute) return;

    final previousRoute = _activeRoute;
    final previousEnteredAt = _activeRouteEnteredAt;

    if (previousRoute != null && previousEnteredAt != null) {
      _trackTelemetry(
        TelemetryEvents.screenDwell,
        properties: {
          'screen': previousRoute,
          'dwell_ms': now.difference(previousEnteredAt).inMilliseconds,
        },
      );
    }

    _activeRoute = currentRoute;
    _activeRouteEnteredAt = now;
    _trackTelemetry(
      TelemetryEvents.screenView,
      properties: {'screen': currentRoute},
    );
  }

  void _trackStartupAfterFirstFrame() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _trackTelemetry(
        TelemetryEvents.appStartupComplete,
        properties: {
          'startup_ms':
              DateTime.now().difference(_appLaunchStartedAt).inMilliseconds,
        },
      );
    });
  }

  String _routerLocation() {
    final location =
        AppGoRouter.router.routeInformationProvider.value.uri.toString().trim();
    return location.isEmpty ? '/' : location;
  }

  void _reportException(
    Object error,
    StackTrace stackTrace, {
    required String source,
    required bool fatal,
  }) {
    final errorFingerprint = _errorFingerprint(error, stackTrace);
    _trackTelemetry(
      TelemetryEvents.appException,
      properties: {
        'error_type': error.runtimeType.toString(),
        'error_fingerprint': errorFingerprint,
        'source': source,
        'fatal': fatal,
      },
    );

    log('[MyApp] unhandled error from $source: $error', stackTrace: stackTrace);
  }

  String _errorFingerprint(Object error, StackTrace stackTrace) {
    final topFrames = stackTrace
        .toString()
        .split('\n')
        .take(3)
        .join('|')
        .replaceAll(RegExp(r'\d+'), '#');
    final seed = '${error.runtimeType}|$topFrames';
    var hash = 0x811c9dc5;
    for (final codeUnit in seed.codeUnits) {
      hash ^= codeUnit;
      hash = (hash * 0x01000193) & 0xffffffff;
    }
    return hash.toRadixString(16).padLeft(8, '0');
  }

  void _trackTelemetry(
    String event, {
    Map<String, Object>? properties,
  }) {
    try {
      ref.read(telemetryServiceProvider).track(
            event,
            properties: properties,
          );
    } catch (e, st) {
      log('[MyApp] telemetry track failed for "$event": $e', stackTrace: st);
    }
  }

  Future<void> _initExternalProcessText() async {
    try {
      _processTextSub = ExternalProcessTextService.instance.textStream.listen(
        _handleIncomingText,
      );
      await ExternalProcessTextService.instance.initialize();
    } catch (e, st) {
      log('[MyApp] external process text init failed: $e', stackTrace: st);
    }
  }

  void _handleIncomingText(String text) {
    final classification = classifyExternalText(text);
    final payload = {
      'type': classification.type.name,
      'prefill': classification.prefill,
      'sourceText': text,
      'source': 'process_text',
    };

    // Ensure user lands in Generate section then opens the right prefilled form.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      AppGoRouter.router.go(AppPath.generateHome);
      AppGoRouter.router.push(AppPath.generateCode, extra: payload);
    });
  }

  Future<void> _checkForUpdates() async {
    final status = await updater.checkForUpdate();
    if (status == UpdateStatus.outdated) {
      try {
        await updater.update();
      } on UpdateException catch (e) {
        log('[MyApp] OTA update failed: $e');
      }
    }
  }

  @override
  void dispose() {
    AppGoRouter.router.routerDelegate.removeListener(_onRouteChanged);
    final activeRoute = _activeRoute;
    final enteredAt = _activeRouteEnteredAt;
    if (activeRoute != null && enteredAt != null) {
      _trackTelemetry(
        TelemetryEvents.screenDwell,
        properties: {
          'screen': activeRoute,
          'dwell_ms': DateTime.now().difference(enteredAt).inMilliseconds,
        },
      );
    }

    _performanceService.stop();
    unawaited(_backgroundSyncService.stop());
    unawaited(QRIsolate.dispose());
    _processTextSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Eagerly initialize persisted user settings so feedback toggles
    // (vibrate/beep) apply before first user interactions.
    ref.watch(settingsProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      builder: (context, child) =>
          NotificationOverlay(child: child ?? const SizedBox.shrink()),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      supportedLocales: L10n.all,
      themeMode: ThemeMode.system,
      theme: GlobalThemData.lightThemeData,
      darkTheme: GlobalThemData.darkThemeData,
      locale: locale,
      title: "Scagen",
      routerConfig: AppGoRouter.router,
    );
  }
}
