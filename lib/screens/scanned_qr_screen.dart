import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';
import '../providers/qr_providers.dart';
import '../services/telemetry_service.dart';
import '../widgets/background_screen_widget.dart';

class ScannedQRScreen extends ConsumerWidget {
  const ScannedQRScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final qrData = ref.watch(scannedQRDataProvider) ?? '';

    return BackgroundScreenWidget(
      screenTitle: l10n.scan,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            // Scanned data card
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xff3C3C3C),
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xff000000).withValues(alpha: 0.25),
                    offset: const Offset(0, 4),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.scannedResultTitle,
                      style: TextStyle(
                        color: Color(0xffFDB623),
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      qrData,
                      style: const TextStyle(
                        color: Color(0xffD9D9D9),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 6,
                    ),
                  ],
                ),
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
            // QR code display
            Center(
              child: Container(
                height: 225,
                width: 225,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xffF5F5F5).withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xff000000).withValues(alpha: 0.25),
                      offset: const Offset(0, 4),
                      blurRadius: 4,
                    ),
                  ],
                  border: Border.all(
                    color: const Color(0xffFDB623),
                    width: 5,
                  ),
                ),
                child: qrData.isNotEmpty
                    ? QrImageView(
                        data: qrData,
                        version: QrVersions.auto,
                        size: 200.0,
                      )
                    : Center(child: Text(l10n.noData)),
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
            // Action buttons
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Copy button
                  Column(
                    children: [
                      InkWell(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: qrData));
                          ref.read(telemetryServiceProvider).track(
                            TelemetryEvents.qrCopied,
                            properties: {'source': 'scanned'},
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(l10n.snackbarCopiedToClipboard)),
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
                                    const Color(0xff000000).withValues(alpha: 0.25),
                                offset: const Offset(0, 4),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.copy,
                            color: Color(0xff3C3C3C),
                          ),
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        l10n.copyBtn,
                        style: TextStyle(
                          color: Color(0xffD9D9D9),
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 40),
                  // Open URL button (if it's a URL)
                  if (Uri.tryParse(qrData)?.hasScheme == true)
                    Column(
                      children: [
                        InkWell(
                          onTap: () async {
                            final uri = Uri.parse(qrData);
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri,
                                  mode: LaunchMode.externalApplication);
                              ref.read(telemetryServiceProvider).track(TelemetryEvents.qrUrlOpened);
                            }
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
                                      const Color(0xff000000).withValues(alpha: 0.25),
                                  offset: const Offset(0, 4),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.open_in_browser,
                              color: Color(0xff3C3C3C),
                            ),
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          l10n.openBtn,
                          style: TextStyle(
                            color: Color(0xffD9D9D9),
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  if (Uri.tryParse(qrData)?.hasScheme == true)
                    const SizedBox(width: 40),
                  // Share button
                  Column(
                    children: [
                      InkWell(
                        onTap: () async {
                          try {
                            await SharePlus.instance
                                .share(ShareParams(text: qrData));
                            ref.read(telemetryServiceProvider).track(
                              TelemetryEvents.qrShared,
                              properties: {'source': 'scanned'},
                            );
                          } catch (e, st) {
                            dev.log(
                              '[ScannedQRScreen] share failed: $e',
                              stackTrace: st,
                              name: 'ScannedQRScreen',
                            );
                          }
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
                                    const Color(0xff000000).withValues(alpha: 0.25),
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
                        l10n.shareBtn,
                        style: const TextStyle(
                          color: Color(0xffD9D9D9),
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
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
