import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../models/qr_record.dart';
import '../providers/qr_providers.dart';
import '../utils/app_router.dart';
import '../utils/route/app_path.dart';

class ScanHomeScreen extends ConsumerStatefulWidget {
  const ScanHomeScreen({super.key});

  @override
  ConsumerState<ScanHomeScreen> createState() => _ScanHomeScreenState();
}

class _ScanHomeScreenState extends ConsumerState<ScanHomeScreen> {
  final MobileScannerController controller = MobileScannerController();
  String? qrScan;
  bool _hasNavigated = false;

  void _onDetect(BarcodeCapture capture) {
    if (_hasNavigated) return;
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
      final data = barcodes.first.rawValue!;
      setState(() {
        qrScan = data;
        _hasNavigated = true;
      });

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

      // Navigate to scanned result
      AppGoRouter.router.push(AppPath.scannedQRResult);
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
                      // TODO: pick from gallery
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
