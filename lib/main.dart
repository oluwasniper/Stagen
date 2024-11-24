import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:appwrite/appwrite.dart' as appwrite;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:revolutionary_stuff/l10n/l10n.dart';
import 'package:revolutionary_stuff/router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  // await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  appwrite.Client client = appwrite.Client();
  client.setProject('6742d23d00333f806b41');

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        DefaultMaterialLocalizations.delegate,
        DefaultCupertinoLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
      supportedLocales: L10n.all,
      locale: L10n.all[0],
      title: AppLocalizations.of(context)!.appName,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
