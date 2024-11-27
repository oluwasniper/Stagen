import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:revolutionary_stuff/utils/app_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
        value: SystemUiOverlayStyle(
          statusBarColor: Color(0xffFDB623),
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Color(0xffFDB623),
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        child: Scaffold(
          backgroundColor: Color(0xffFDB623),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text('Onboarding Screens'),
                Text(
                  AppLocalizations.of(context)!.generateCode,
                ),
                ElevatedButton(
                  onPressed: () {
                    router.go('/bottomnav'); //this is like pushAndRemoveUntil
                    // router.push(location) //this is like push
                    // router.replace(location) //this is like pushReplacement
                    // router.back() //this is like pop
                    // router.popUntil(location) //this is like popUntil
                    // router.popAndPush(location) //this is like popAndPushNamed
                    // router.popUntilAndPush(location) //this is like popUntilAndPushNamed
                  },
                  child: const Text('Go to Home'),
                ),
              ],
            ),
          ),
        ));
  }
}
