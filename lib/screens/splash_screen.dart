import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/app_router.dart';
import '../utils/route/app_path.dart';
import '../widgets/splash_logo_widget.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    /// AnnotatedRegion is used to set the system UI overlay style

    return AnnotatedRegion(
      /// SystemChrome.setEnabledSystemUIMode is used to set the system UI mode
      value: SystemChrome.setEnabledSystemUIMode(

          /// Manual mode for controlling system UI (status bar and navigation bar).
          /// This gives full control over system chrome settings and visibility.
          /// Use this with [SystemChrome.setSystemUIMode] and [SystemChrome.setEnabledSystemUIMode].

          SystemUiMode.manual,
          overlays: [
            SystemUiOverlay.top,
          ]),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          /// statusBarColor is used to set the color of the status bar
          statusBarColor: Color(0xffFDB623),

          /// statusBarIconBrightness is used to set the brightness of the status bar icons
          statusBarIconBrightness: Brightness.dark,

          /// systemNavigationBarColor is used to set the color of the system navigation bar
          systemNavigationBarColor: Color(0xffFDB623),

          /// systemNavigationBarIconBrightness is used to set the brightness of the system navigation bar icons
          systemNavigationBarIconBrightness: Brightness.dark,
        ),

        /// FlutterSplashScreen is used to show the splash screen
        child: FlutterSplashScreen(
          /// SplashLogoWidget is used to show the logo on the splash screen
          splashScreenBody: SplashLogoWidget(),

          /// backgroundColor is used to set the background color of the splash screen
          backgroundColor: Color(0xffFDB623),

          /// duration is used to set the duration of the splash screen
          duration: Duration(seconds: 3),

          /// onEnd is used to navigate to the next screen after the splash screen ends
          onEnd: () {
            /// AppGoRouter.router.go is used to navigate to the next screen
            AppGoRouter.router.go(AppPath.onboarding);
          },
        ),
      ),
    );
  }
}
