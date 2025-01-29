import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../widgets/background_screen_widget.dart';
import '../widgets/generate_qr_widget.dart';
import '../widgets/generate_qr_code_body_widget.dart';

class GenerateCodeScreen extends StatelessWidget {
  final QROption type;
  const GenerateCodeScreen({
    super.key,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return BackgroundScreenWidget(
      screenTitle: type.label,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 0,
            bottom: 30,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Color(0xff3B3B3B).withOpacity(0.78),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.symmetric(
                      horizontal: BorderSide(
                        color: Color(0xffFDB623),
                        width: 3,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xff000000).withOpacity(0.25),
                        offset: Offset(0, 4),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: SvgPicture.asset(
                          type.svgData,
                          colorFilter: ColorFilter.mode(
                            Color(0xffFDB623),
                            BlendMode.srcIn,
                          ),
                          width: 70,
                          height: 70,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                        ),
                        child: GenerateQRCodeBody(type: type),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(30.0),
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xffFDB623),
                            padding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: Text(
                            // 'Generate QR Code',
                            AppLocalizations.of(context)!.generateQRCodeBtn,
                            style: TextStyle(
                              color: Color(0xff333333),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
