
import 'package:flutter/cupertino.dart';
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
        // MobileScanner(
        //   onDetect: (capture) {
        //     final List<Barcode> barcodes = capture.barcodes;
        //     for (final barcode in barcodes) {
        //       if (barcode.rawValue != null) {
        //         log(barcode.rawValue!);
        //       } else {
        //         log('Barcode value is null');
        //       }
        //     }
        //   },
        // )

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
            width: scanArea,
            height: scanArea,
          ),
        ),
      ],
    );
  }
}
