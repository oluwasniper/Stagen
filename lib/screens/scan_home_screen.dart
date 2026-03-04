import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../l10n/app_localizations.dart';
import '../models/qr_record.dart';
import '../providers/qr_providers.dart';
import '../providers/settings_provider.dart';
import '../services/telemetry_service.dart';
import '../utils/app_router.dart';
import '../utils/route/app_path.dart';

class ScanHomeScreen extends ConsumerStatefulWidget {
  const ScanHomeScreen({super.key});

  @override
  ConsumerState<ScanHomeScreen> createState() => _ScanHomeScreenState();
}

class _ScanHomeScreenState extends ConsumerState<ScanHomeScreen> {
  final MobileScannerController controller = MobileScannerController();
  final ImagePicker _imagePicker = ImagePicker();
  String? qrScan;
  bool _hasNavigated = false;

  String _classifyContent(String data) {
    final lower = data.toLowerCase();
    if (lower.startsWith('http://') || lower.startsWith('https://')) return 'url';
    if (lower.startsWith('mailto:')) return 'email';
    if (lower.startsWith('tel:')) return 'phone';
    if (lower.startsWith('wifi:')) return 'wifi';
    if (lower.startsWith('begin:vcard')) return 'contact';
    if (lower.startsWith('begin:vevent')) return 'event';
    if (lower.startsWith('geo:')) return 'location';
    return 'text';
  }

  Future<void> _handleScannedData(String data) async {
    if (_hasNavigated) return;
    setState(() {
      qrScan = data;
      _hasNavigated = true;
    });

    final settings = ref.read(settingsProvider);
    if (settings.vibrate) {
      HapticFeedback.mediumImpact();
    }
    if (settings.beep) {
      SystemSound.play(SystemSoundType.click);
    }

    ref.read(telemetryServiceProvider).track(
      TelemetryEvents.qrScanned,
      properties: {'content_type': _classifyContent(data)},
    );

    // Store scanned data in provider
    ref.read(scannedQRDataProvider.notifier).state = data;

    // Save to Appwrite
    final record = QRRecord(
      data: data,
      type: 'scanned',
      qrType: 'scan',
      label: 'Scanned QR',
    );
    ref.read(scannedHistoryProvider.notifier).addRecord(record);

    try {
      await controller.stop();
      await AppGoRouter.router.push(AppPath.scannedQRResult);
    } finally {
      if (mounted) {
        setState(() => _hasNavigated = false);
        await controller.start();
      } else {
        _hasNavigated = false;
      }
    }
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_hasNavigated) return;
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
      final data = barcodes.first.rawValue!;
      await _handleScannedData(data);
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final image = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      final capture = await controller.analyzeImage(image.path);
      String? code;
      if (capture != null && capture.barcodes.isNotEmpty) {
        code = capture.barcodes.first.rawValue;
      }
      if (code == null || code.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).noQrFoundInImage)),
        );
        return;
      }
      await _handleScannedData(code);
    } catch (e, st) {
      dev.log(
        '[ScanHomeScreen] gallery scan failed: $e',
        stackTrace: st,
        name: 'ScanHomeScreen',
      );
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MobileScanner(
          controller: controller,
          onDetect: _onDetect,
          fit: BoxFit.contain,
          scanWindow: Rect.fromCenter(
            center: Offset(
              MediaQuery.of(context).size.width / 2,
              MediaQuery.of(context).size.height / 2,
            ),
            width: MediaQuery.of(context).size.width - 60,
            height: MediaQuery.of(context).size.width - 60,
          ),
        ),
        Positioned(
            top: 50,
            left: 30,
            right: 30,
            child: Container(
              height: 45,
              width: MediaQuery.of(context).size.width - 60,
              decoration: BoxDecoration(
                color: const Color(0xFF000000).withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      _pickFromGallery();
                    },
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                      child: Icon(Icons.photo_library_rounded),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      controller.toggleTorch();
                      ref.read(telemetryServiceProvider).track(TelemetryEvents.scannerTorchToggled);
                    },
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                      child: Icon(Icons.flash_on_rounded),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      controller.switchCamera();
                      ref.read(telemetryServiceProvider).track(TelemetryEvents.scannerCameraSwitched);
                    },
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                      child: Icon(Icons.flip_camera_ios_rounded),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}
