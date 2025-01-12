import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/app_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../utils/route/app_path.dart';
import '../widgets/splash_logo_widget.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ///Use MediaQuery to get the size of the screen
    ///Use it to calculate the size of the icon
    final iconSize = MediaQuery.sizeOf(context).width * 0.6;

    /// Creates an [AnnotatedRegion] widget that applies system UI overlay styles
    /// to its descendant widgets.
    ///
    /// The [AnnotatedRegion] widget is typically used to modify the appearance of
    /// system UI elements like the status bar and navigation bar on the device.
    /// This widget must be properly configured with a value parameter that defines
    /// the desired system UI overlay settings.
    return AnnotatedRegion(
      value:
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [
        SystemUiOverlay.bottom,
        SystemUiOverlay.top,
      ]),
      child: AnnotatedRegion(
          value: SystemUiOverlayStyle(
            statusBarColor: Color(0xffFDB623),
            statusBarIconBrightness: Brightness.light,
            systemNavigationBarColor: Color(0xff333333),
            systemNavigationBarIconBrightness: Brightness.light,
            systemNavigationBarDividerColor: Color(0xff333333),
          ),
          child: Scaffold(
              backgroundColor: Color(0xffFDB623),
              body: Column(
                children: <Widget>[
                  SplashLogoWidget(),
                  Spacer(),
                  Container(
                    height: iconSize,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(61),
                        topRight: Radius.circular(61),
                      ),
                      color: Color(0xff333333),
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          Container(
                            height: 5,
                            width: 120,
                            margin: EdgeInsets.only(top: 15, bottom: 10),
                            decoration: BoxDecoration(
                              color: Color(0xffFDB623),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          Text(
                            /// Returns the onboarding header text string from the localized resources
                            /// based on the current context's locale.
                            AppLocalizations.of(context)!.onboardingHeader,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 42,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(
                            width: 350,
                            child: Text(
                              AppLocalizations.of(context)!.onboardingSubHeader,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w300,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xffFDB623),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              // padding: EdgeInsets.symmetric(horizontal: 90),
                              fixedSize: Size(350, 50),
                            ),
                            onPressed: () {
                              /// Navigates to the home screen using the goRouter instance.
                              ///
                              /// Different routing options available:
                              /// - `go(path)`: Simple navigation, adds to history stack
                              /// - `push(path)`: Pushes route on top of stack
                              /// - `replace(path)`: Replaces current route
                              /// - `goNamed(name)`: Navigates using named route
                              /// - `pushNamed(name)`: Pushes named route
                              /// - `replaceNamed(name)`: Replaces with named route
                              ///
                              /// For routes with parameters:
                              /// - Include params in path: `/user/:id`
                              /// - Or pass params object: `go('/user', params: {'id': '123'})`
                              ///
                              /// Can also pass extra data:
                              /// ```
                              /// go(path, extra: yourData)
                              /// ```
                              AppGoRouter.router.go(AppPath.home);
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Icon(
                                  Icons.arrow_forward,
                                  color: Color(0xffFDB623),
                                ),
                                Text(
                                    AppLocalizations.of(context)!
                                        .onboardingSkipButton,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w300,
                                    )),
                                Icon(
                                  Icons.arrow_forward,
                                  color: Colors.black,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    /// Applies a fade-in and slide animation to the widget using the Animate extension.
                    /// Part of the widget's animation chain for onboarding screen transitions.
                  ).animate().fadeIn().slide(
                      begin: Offset(0, 1.5),
                      end: Offset(0, 0),
                      curve: Curves.easeInOutCubic,
                      duration: Duration(milliseconds: 1500)),
                ],
              ))),
    );
  }
}
