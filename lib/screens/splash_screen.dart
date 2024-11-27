import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:revolutionary_stuff/router.dart';
import 'package:revolutionary_stuff/utils/app_asset.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final iconSize = MediaQuery.sizeOf(context).width - 150;
    return AnnotatedRegion(
      value:
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [
        SystemUiOverlay.top,
      ]),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Color(0xffFDB623),
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: Color(0xffFDB623),
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        child: FlutterSplashScreen(
          splashScreenBody: Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 200.0),
              child: Image.asset(
                kAsset.icon,
                height: iconSize,
                width: iconSize,
                filterQuality: FilterQuality.high,
                semanticLabel:
                    '${AppLocalizations.of(context)!.appName} App Icon',
              ),
            ),
          ),
          backgroundColor: Color(0xffFDB623),
          duration: Duration(seconds: 7),
          onEnd: () {
            router.replace('/onboarding');
          },
        ),
      ),
    );
  }
}
