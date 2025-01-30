import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanHomeScreen extends StatefulWidget {
  const ScanHomeScreen({super.key});

  @override
  State<ScanHomeScreen> createState() => _ScanHomeScreenState();
}

class _ScanHomeScreenState extends State<ScanHomeScreen> {
  final MobileScannerController controller = MobileScannerController();
  String? qrScan;
  bool redirect = false;
  final double scanArea = 300.0; // Define the scanArea variable

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
            top: 50,
            left: 30,
            right: 30,
            child: Container(
              height: 45,
              width: MediaQuery.of(context).size.width - 60,
              decoration: BoxDecoration(
                color: Color(0xFF000000).withOpacity(0.4),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {},
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                      child: Icon(Icons.photo_library_rounded),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                      child: Icon(Icons.flash_on_rounded),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                      child: Icon(Icons.flip_camera_ios_rounded),
                    ),
                  ),
                ],
              ),
            )),
        MobileScanner(
          controller: controller,
          onDetect: (BarcodeCapture capture) {
            final List<Barcode> barcodes = capture.barcodes;
            if (barcodes.isNotEmpty) {
              setState(() {
                qrScan = barcodes.first.rawValue;
                redirect = true;
              });
            }
          },
          fit: BoxFit.contain,
          scanWindow: Rect.fromCenter(
            center: Offset(
              MediaQuery.of(context).size.width / 2,
              MediaQuery.of(context).size.height / 2,
            ),
            // width: scanArea,
            width: MediaQuery.of(context).size.width - 60,
            // height: scanArea,
            height: MediaQuery.of(context).size.width - 60,
          ),
        ),
      ],
    );
  }
}
