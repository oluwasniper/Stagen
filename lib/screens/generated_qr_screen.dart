import 'dart:developer' as dev;
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../l10n/app_localizations.dart';
import '../providers/qr_providers.dart';
import '../services/telemetry_service.dart';
import '../widgets/background_screen_widget.dart';

class GeneratedQRScreen extends ConsumerStatefulWidget {
  const GeneratedQRScreen({super.key});

  @override
  ConsumerState<GeneratedQRScreen> createState() => _GeneratedQRScreenState();
}

class _GeneratedQRScreenState extends ConsumerState<GeneratedQRScreen> {
  final _qrKey = GlobalKey();

  Future<Uint8List?> _captureQrImage() async {
    final boundary =
        _qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return null;
    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  Future<void> _copyQrImage(BuildContext context) async {
    try {
      final bytes = await _captureQrImage();
      if (bytes == null) return;
      await Pasteboard.writeImage(bytes);
      ref.read(telemetryServiceProvider).track(
        TelemetryEvents.qrCopied,
        properties: {'source': 'generated'},
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  AppLocalizations.of(context).snackbarCopiedToClipboard)),
        );
      }
    } catch (e, st) {
      dev.log(
        '[GeneratedQRScreen] copy failed: $e',
        stackTrace: st,
        name: 'GeneratedQRScreen',
      );
    }
  }

  Future<void> _shareQrImage(String label) async {
    try {
      final bytes = await _captureQrImage();
      if (bytes == null) return;

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/qr_code.png');
      await file.writeAsBytes(bytes);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          fileNameOverrides: ['${label}_qr.png'],
        ),
      );
      ref.read(telemetryServiceProvider).track(
        TelemetryEvents.qrShared,
        properties: {'source': 'generated'},
      );
    } catch (e, st) {
      dev.log(
        '[GeneratedQRScreen] share failed: $e',
        stackTrace: st,
        name: 'GeneratedQRScreen',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final qrData = ref.watch(generatedQRDataProvider) ?? '';
    final label = ref.watch(generatedQRLabelProvider) ?? l10n.qrCode;
    final qrType = ref.watch(generatedQRTypeProvider) ?? '';

    return BackgroundScreenWidget(
      screenTitle: label,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            // Data info card
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
                      qrType.isNotEmpty
                          ? qrType[0].toUpperCase() + qrType.substring(1)
                          : l10n.generatedLabel,
                      style: const TextStyle(
                        color: Color(0xffFDB623),
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      qrData,
                      style: const TextStyle(
                        color: Color(0xffD9D9D9),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
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
                    ? RepaintBoundary(
                        key: _qrKey,
                        child: QrImageView(
                          data: qrData,
                          version: QrVersions.auto,
                          size: 200.0,
                        ),
                      )
                    : Center(
                        child: Text(l10n.noData),
                      ),
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
                        onTap: () => _copyQrImage(context),
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
                  // Share button
                  Column(
                    children: [
                      InkWell(
                        onTap: () => _shareQrImage(label),
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
