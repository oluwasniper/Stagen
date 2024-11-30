import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:revolutionary_stuff/utils/app_router.dart';
import 'package:revolutionary_stuff/widgets/splash_logo_widget.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
          splashScreenBody: SplashLogoWidget(),
          backgroundColor: Color(0xffFDB623),
          duration: Duration(seconds: 3),
          onEnd: () {
            // router.replace('/onboarding');
            AppGoRouter.router.go('/onboarding');
          },
        ),
      ),
    );
  }
}
