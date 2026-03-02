import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../l10n/app_localizations.dart';
import '../models/qr_record.dart';
import '../widgets/background_screen_widget.dart';

class ShowQrScreen extends StatefulWidget {
  final QRRecord? record;
  const ShowQrScreen({super.key, this.record});

  @override
  State<ShowQrScreen> createState() => _ShowQrScreenState();
}

class _ShowQrScreenState extends State<ShowQrScreen> {
  @override
  Widget build(BuildContext context) {
    final record = widget.record;
    final data = record?.data ?? '';
    final qrType = record?.qrType ?? 'Unknown';

    return BackgroundScreenWidget(
      screenTitle: AppLocalizations.of(context)!.qrCode,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: ListView(
          children: [
            Container(
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
                        vertical: 10, horizontal: 10),
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
                          data,
                          style: const TextStyle(
                            color: Color(0xffA4A4A4),
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
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
            const SizedBox(height: 40),
            Center(
              child: Container(
                height: 225,
                width: 225,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xffF5F5F5).withOpacity(0.85),
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xff000000).withOpacity(0.25),
                      offset: const Offset(0, 4),
                      blurRadius: 4,
                    ),
                  ],
                  border: Border.all(
                    color: const Color(0xffFDB623),
                    width: 5,
                  ),
                ),
                child: data.isNotEmpty
                    ? QrImageView(
                        data: data,
                        version: QrVersions.auto,
                        size: 200.0,
                      )
                    : const Center(child: Text('No data')),
              ),
            )
                .animate()
                .scale(
                  begin: const Offset(0.5, 0.5),
                  end: const Offset(1, 1),
                  delay: const Duration(milliseconds: 200),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutBack,
                )
                .fadeIn(
                  delay: const Duration(milliseconds: 200),
                  duration: const Duration(milliseconds: 400),
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
                        AppLocalizations.of(context)!.shareBtn,
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
                                content: Text(AppLocalizations.of(context)!
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
                            Icons.save_alt_rounded,
                            color: Color(0xff3C3C3C),
                          ),
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        AppLocalizations.of(context)!.saveBtn,
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
                  delay: const Duration(milliseconds: 500),
                  duration: const Duration(milliseconds: 400),
                )
                .slideY(
                  begin: 0.2,
                  end: 0,
                  delay: const Duration(milliseconds: 500),
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOut,
                ),
          ],
        ),
      ),
    );
  }
}
