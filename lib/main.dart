import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// to use he l10n, you nee to import the generated file
import 'l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:revolutionary_stuff/utils/app_theme.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:revolutionary_stuff/services/telemetry_service.dart';
import 'package:revolutionary_stuff/services/offline_history_service.dart';

import 'l10n/l10n.dart';
import 'providers/settings_provider.dart';
import 'utils/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await initPostHog();
  await Hive.initFlutter();
  await OfflineHistoryService.instance.init();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
  return;
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  final updater = ShorebirdUpdater();

  @override
  void initState() {
    super.initState();
    updater.readCurrentPatch().then((currentPatch) {
      log('The current patch number is: ${currentPatch?.number}');
    });
    _checkForUpdates();
  }

  Future<void> _checkForUpdates() async {
    final status = await updater.checkForUpdate();
    if (status == UpdateStatus.outdated) {
      try {
        await updater.update();
      } on UpdateException {
        // Handle any errors that occur while updating.
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      supportedLocales: L10n.all,
      themeMode: ThemeMode.dark,
      theme: GlobalThemData.lightThemeData,
      darkTheme: GlobalThemData.darkThemeData,
      locale: locale,
      title: "Scagen",
      routerConfig: AppGoRouter.router,
    );
  }
}
