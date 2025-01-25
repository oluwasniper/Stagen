import 'package:flutter/material.dart';
import '../utils/app_asset.dart';
import '../utils/app_router.dart';
import '../utils/route/app_path.dart';
import '../widgets/background_screen_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class OpenFileScreen extends StatefulWidget {
  const OpenFileScreen({super.key});

  @override
  State<OpenFileScreen> createState() => _OpenFileScreenState();
}

class _OpenFileScreenState extends State<OpenFileScreen> {
  @override
  Widget build(BuildContext context) {
    return BackgroundScreenWidget(
      screenTitle: AppLocalizations.of(context)!.openFileHeader,
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 30,
        ),
        child: ListView(
          physics: BouncingScrollPhysics(),
          children: [
            Container(
              height: 180,
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
                        vertical: 15, horizontal: 20),
                    child: Row(
                      children: [
                        // add icon as png
                        Image.asset(
                          AppAsset.iconNoBGPNG,
                          height: 50,
                          width: 50,
                          filterQuality: FilterQuality.high,
                        ),

                        Padding(
                          padding: const EdgeInsets.only(left: 20),
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
                                "16 Dec 2022, 9:30 pm",
                                style: TextStyle(
                                  color: Color(0xffA4A4A4),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    child: Divider(
                      color: Color(0xff858585),
                      height: 0.3,
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "https://www.youtube.com/watch?v=Zd9g7sKvgIM",
                          style: TextStyle(
                            color: Color(0xffD9D9D9),
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 2,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              style: TextButton.styleFrom(
                                visualDensity: VisualDensity.compact,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              onPressed: () {
                                AppGoRouter.router.go(AppPath.historyShowQR);
                              },
                              child: Text(
                                AppLocalizations.of(context)!.showQRCode,
                                style: TextStyle(
                                  color: Color(0xffFDB623),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                ),
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
                            Icons.content_copy_rounded,
                            color: Color(0xff3C3C3C),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 7,
                      ),
                      Text(
                        AppLocalizations.of(context)!.copyBtn,
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
