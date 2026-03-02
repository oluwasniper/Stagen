import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ri.dart';

class BackgroundScreenWidget extends StatefulWidget {
  final Widget body;
  final void Function()? actionButton;
  final String screenTitle;

  const BackgroundScreenWidget(
      {super.key,
      required this.body,
      this.actionButton,
      required this.screenTitle});

  @override
  State<BackgroundScreenWidget> createState() => _BackgroundScreenWidgetState();
}

class _BackgroundScreenWidgetState extends State<BackgroundScreenWidget> {
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value:
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [
        SystemUiOverlay.top,
      ]),
      child: AnnotatedRegion(
        value: SystemUiOverlayStyle(
          statusBarColor: Color(0xff4E4E4E),
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Color(0xff4E4E4E),
          systemNavigationBarIconBrightness: Brightness.light,
          systemNavigationBarDividerColor: Color(0xff4E4E4E),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Color(0xff525252),
                // color: Color(0xff333333),
              ),
            ),
            Positioned(
                top: -MediaQuery.of(context).size.height * 0.05,
                right: -MediaQuery.of(context).size.height * 0.18,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.5,
                  width: MediaQuery.of(context).size.height * 0.5,
                  decoration: BoxDecoration(
                    color: Color(0xff4E4E4E),
                    borderRadius: BorderRadius.all(
                      Radius.circular(MediaQuery.of(context).size.height),
                    ),
                    border: Border.all(
                      color: Color(0xff616469),
                      width: 0.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xffD9D9D9).withOpacity(0.25),
                        spreadRadius: 0,
                        blurRadius: 4,
                        offset: Offset(1, 1), // changes position of shadow
                      ),
                    ],
                  ),
                )),
            Positioned(
                bottom: -MediaQuery.of(context).size.height * 0.05,
                left: -MediaQuery.of(context).size.height * 0.3,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.5,
                  width: MediaQuery.of(context).size.height * 0.5,
                  decoration: BoxDecoration(
                    color: Color(0xff4E4E4E),
                    borderRadius: BorderRadius.all(
                      Radius.circular(MediaQuery.of(context).size.height),
                    ),
                    border: Border.all(
                      color: Color(0xff616469),
                      width: 0.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xffD9D9D9).withOpacity(0.25),
                        spreadRadius: 0,
                        blurRadius: 4,
                        offset: Offset(1, 1), // changes position of shadow
                      ),
                    ],
                  ),
                )),
            Scaffold(
              // backgroundColor: Color(0xff3D3D3D),

              backgroundColor: Colors.transparent,

              appBar: AppBar(
                backgroundColor: Colors.transparent,
                centerTitle: false,
                bottom: PreferredSize(
                  preferredSize: Size.fromHeight(30),
                  child: Container(),
                ),
                title: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    widget.screenTitle,
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                leadingWidth: 65,
                // show leading  if the action button is null
                leading: widget.actionButton == null
                    ? GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: 20,
                          ),
                          child: Container(
                            margin: EdgeInsets.only(top: 4, bottom: 4),
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                // color: Color(0xffFDB623),
                                color: Color(0xff333333)),
                            child: Iconify(
                              Ri.arrow_left_s_line,
                              size: 40,
                              color: Color(0xffFDB623),
                            ),
                          ),
                        ),
                      )
                    : null,

                // show action button if the action button is not null
                actions: widget.actionButton != null
                    ? [
                        GestureDetector(
                          onTap: () {
                            if (widget.actionButton != null) {
                              widget.actionButton!();
                            }
                          },
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: 20,
                            ),
                            child: Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  // color: Color(0xffFDB623),
                                  color: Color(0xff333333)),
                              child: Iconify(
                                Ri.menu_3_line,
                                size: 30,
                                color: Color(0xffFDB623),
                              ),
                            ),
                          ),
                        ),
                      ]
                    : null,
              ),
              body: widget.body,
            ),
          ],
        ),
      ),
    );
  }
}
