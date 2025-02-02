import 'dart:developer';

import 'package:appwrite/appwrite.dart' as appwrite;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// to use he l10n, you nee to import the generated file
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:revolutionary_stuff/utils/app_theme.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';

import 'l10n/l10n.dart';
import 'utils/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  /// for appwrite integration
  appwrite.Client client = appwrite.Client();
  client.setProject('6742d23d00333f806b41');

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final updater = ShorebirdUpdater();

  @override
  void initState() {
    super.initState();

    // Get the current patch number and print it to the console.
    // It will be `null` if no patches are installed.
    updater.readCurrentPatch().then((currentPatch) {
      log('The current patch number is: ${currentPatch?.number}');
    });

    /// check for updates on app start
    _checkForUpdates();
  }

  Future<void> _checkForUpdates() async {
    // Check whether a new update is available.
    final status = await updater.checkForUpdate();

    if (status == UpdateStatus.outdated) {
      try {
        // Perform the update
        await updater.update();
      } on UpdateException {
        // Handle any errors that occur while updating.
      }
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        DefaultMaterialLocalizations.delegate,
        DefaultCupertinoLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appName,
      supportedLocales: L10n.all,
      themeMode: ThemeMode.dark, //or ThemeMode.light
      theme: GlobalThemData.lightThemeData,
      darkTheme: GlobalThemData.darkThemeData,
      locale: L10n.all[0],
      // title: AppLocalizations.of(context)!.appName,
      title: "Scagen",
      // theme: ThemeData(
      //   colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      //   useMaterial3: true,
      // ),
      // routerConfig: router,
      routerConfig: AppGoRouter.router,
    );
  }
}
