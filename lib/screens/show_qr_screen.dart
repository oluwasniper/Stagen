import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../widgets/background_screen_widget.dart';

class ShowQrScreen extends StatefulWidget {
  const ShowQrScreen({super.key});

  @override
  State<ShowQrScreen> createState() => _ShowQrScreenState();
}

class _ShowQrScreenState extends State<ShowQrScreen> {
  @override
  Widget build(BuildContext context) {
    return BackgroundScreenWidget(
      screenTitle: AppLocalizations.of(context)!.qrCode,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: ListView(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Color(0xff3C3C3C),
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xff000000).withOpacity(0.25),
                    offset: Offset(0, 4),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Data type",
                          style: TextStyle(
                            color: Color(0xffD9D9D9),
                            fontSize: 22,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          "https://www.youtube.com/watch?v=Zd9g7sKvgIM",
                          style: TextStyle(
                            color: Color(0xffA4A4A4),
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 40,
            ),
            Center(
              child: Container(
                height: 225,
                width: 225,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Color(0xffF5F5F5).withOpacity(0.85),
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xff000000).withOpacity(0.25),
                      offset: Offset(0, 4),
                      blurRadius: 4,
                    ),
                  ],
                  border: Border.all(
                    color: Color(0xffFDB623),
                    width: 5,
                  ),
                ),
                child: QrImageView(
                  data: "https://www.youtube.com/watch?v=Zd9g7sKvgIM",
                  version: QrVersions.auto,
                  size: 200.0,
                ),
              ),
            ),
            SizedBox(
              height: 60,
            ),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      InkWell(
                        onTap: () {},
                        child: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            color: Color(0xffFDB623),
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xff000000).withOpacity(0.25),
                                offset: Offset(0, 4),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.share,
                            color: Color(0xff3C3C3C),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 7,
                      ),
                      Text(
                        AppLocalizations.of(context)!.shareBtn,
                        style: TextStyle(
                          color: Color(0xffD9D9D9),
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 40,
                  ),
                  Column(
                    children: [
                      InkWell(
                        onTap: () {},
                        child: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            color: Color(0xffFDB623),
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xff000000).withOpacity(0.25),
                                offset: Offset(0, 4),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.save_alt_rounded,
                            color: Color(0xff3C3C3C),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 7,
                      ),
                      Text(
                        AppLocalizations.of(context)!.saveBtn,
                        style: TextStyle(
                          color: Color(0xffD9D9D9),
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
