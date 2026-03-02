import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../models/qr_record.dart';
import '../utils/app_asset.dart';
import '../utils/app_router.dart';
import '../utils/route/app_path.dart';
import '../widgets/background_screen_widget.dart';

class OpenFileScreen extends StatefulWidget {
  final QRRecord? record;
  const OpenFileScreen({super.key, this.record});

  @override
  State<OpenFileScreen> createState() => _OpenFileScreenState();
}

class _OpenFileScreenState extends State<OpenFileScreen> {
  @override
  Widget build(BuildContext context) {
    final record = widget.record;
    final data = record?.data ?? 'No data';
    final qrType = record?.qrType ?? 'Unknown';
    final dateStr = record != null
        ? DateFormat('dd MMM yyyy, h:mm a').format(record.createdAt)
        : '';

    return BackgroundScreenWidget(
      screenTitle: AppLocalizations.of(context).openFileHeader,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xff3C3C3C),
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xff000000).withOpacity(0.25),
                    offset: const Offset(0, 4),
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
                                qrType[0].toUpperCase() + qrType.substring(1),
                                style: const TextStyle(
                                  color: Color(0xffD9D9D9),
                                  fontSize: 22,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              Text(
                                dateStr,
                                style: const TextStyle(
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
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Divider(
                      color: const Color(0xff858585),
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
                          data,
                          style: const TextStyle(
                            color: Color(0xffD9D9D9),
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
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
                                AppGoRouter.router.push(
                                  AppPath.historyShowQR,
                                  extra: record,
                                );
                              },
                              child: Text(
                                AppLocalizations.of(context).showQRCode,
                                style: const TextStyle(
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
            )
                .animate()
                .fadeIn(duration: const Duration(milliseconds: 400))
                .slideY(
                  begin: -0.1,
                  end: 0,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOut,
                ),
            const SizedBox(height: 60),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      InkWell(
                        onTap: () {
                          // TODO: implement share
                        },
                        child: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xffFDB623),
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    const Color(0xff000000).withOpacity(0.25),
                                offset: const Offset(0, 4),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.share,
                            color: Color(0xff3C3C3C),
                          ),
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        AppLocalizations.of(context).shareBtn,
                        style: const TextStyle(
                          color: Color(0xffD9D9D9),
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 40),
                  Column(
                    children: [
                      InkWell(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: data));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(AppLocalizations.of(context)
                                    .snackbarCopiedToClipboard)),
                          );
                        },
                        child: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xffFDB623),
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    const Color(0xff000000).withOpacity(0.25),
                                offset: const Offset(0, 4),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.content_copy_rounded,
                            color: Color(0xff3C3C3C),
                          ),
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        AppLocalizations.of(context).copyBtn,
                        style: const TextStyle(
                          color: Color(0xffD9D9D9),
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            )
                .animate()
                .fadeIn(
                  delay: const Duration(milliseconds: 300),
                  duration: const Duration(milliseconds: 400),
                )
                .slideY(
                  begin: 0.2,
                  end: 0,
                  delay: const Duration(milliseconds: 300),
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOut,
                ),
          ],
        ),
      ),
    );
  }
}
