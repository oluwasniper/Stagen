import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:revolutionary_stuff/utils/app_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:revolutionary_stuff/widgets/splash_logo_widget.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final iconSize = MediaQuery.sizeOf(context).width * 0.6;
    return AnnotatedRegion(
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
                ListView(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    children: [
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
                            Text(AppLocalizations.of(context)!.onboardingHeader,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 42,
                                  fontWeight: FontWeight.w400,
                                )),
                            SizedBox(
                              width: 350,
                              child: Text(
                                AppLocalizations.of(context)!
                                    .onboardingSubHeader,
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
                                router.go(
                                    '/bottomnav'); //this is like pushAndRemoveUntil
                                // router.push(location) //this is like push
                                // router.replace(location) //this is like pushReplacement
                                // router.back() //this is like pop
                                // router.popUntil(location) //this is like popUntil
                                // router.popAndPush(location) //this is like popAndPushNamed
                                // router.popUntilAndPush(location) //this is like popUntilAndPushNamed
                              },
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                        )),
                      ),
                    ]).animate().fadeIn().slide(
                    begin: Offset(0, 1.5),
                    end: Offset(0, 0),
                    curve: Curves.easeInOutCubic,
                    duration: Duration(milliseconds: 1500)),
              ],
            )));
  }
}
