import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:revolutionary_stuff/utils/app_asset.dart';
import 'package:revolutionary_stuff/utils/app_router.dart';
import 'package:revolutionary_stuff/utils/route/app_path.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ri.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GenerateHomeScreen extends StatelessWidget {
  const GenerateHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff3D3D3D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: false,
        title: Padding(
          padding: EdgeInsets.only(left: 46),
          child: Text(
            AppLocalizations.of(context)!.generateQR,
            style: TextStyle(
              color: Color(0xffD9D9D9),
              fontSize: 27,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              AppGoRouter.router.push(AppPath.settings);
            },
            child: Container(
              margin: EdgeInsets.only(right: 31),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Color(0xff333333),
              ),
              child: Iconify(
                Ri.menu_3_line,
                size: 30,
                color: Color(0xffFDB623),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 30,
          vertical: 90,
        ),
        child: SizedBox(
          child: GridView.builder(
            physics: BouncingScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 40),
            itemCount: QROptions.getOptions(context).length,
            itemBuilder: (context, index) {
              final option = QROptions.getOptions(context)[index];
              return QROptionCard(option: option);
            },
          ),
        ),
      ),
    );
  }
}

// create enum for qr options
enum QROptionType {
  text,
  website,
  wifi,
  event,
  contact,
  business,
  location,
  whatsapp,
  email,
  twitter,
  instagram,
  telephone,
}

class QROption {
  final String label;
  final String svgData;
  final QROptionType type;

  const QROption({
    required this.label,
    required this.svgData,
    required this.type,
  });
}

class QROptions {
  static List<QROption> getOptions(BuildContext context) {
    return [
      QROption(
        label: AppLocalizations.of(context)!.textQR,
        svgData: AppAsset.textIconSvg,
        type: QROptionType.text,
      ),
      QROption(
        label: AppLocalizations.of(context)!.websiteQR,
        svgData: AppAsset.websiteIconSvg,
        type: QROptionType.website,
      ),
      QROption(
        label: AppLocalizations.of(context)!.wifiQR,
        svgData: AppAsset.wifiIconSvg,
        type: QROptionType.wifi,
      ),
      // event
      QROption(
        label: AppLocalizations.of(context)!.eventQR,
        svgData: AppAsset.eventIconSvg,
        type: QROptionType.event,
      ),
      // contact
      QROption(
        label: AppLocalizations.of(context)!.contactQR,
        svgData: AppAsset.contactIconSvg,
        type: QROptionType.contact,
      ),
      // business
      QROption(
        label: AppLocalizations.of(context)!.businessQR,
        svgData: AppAsset.businessIconSvg,
        type: QROptionType.business,
      ),
      // location
      QROption(
        label: AppLocalizations.of(context)!.locationQR,
        svgData: AppAsset.locationIconSvg,
        type: QROptionType.location,
      ),
      // whatsapp
      QROption(
        label: AppLocalizations.of(context)!.whatsappQR,
        svgData: AppAsset.whatsappIconSvg,
        type: QROptionType.whatsapp,
      ),
      // email
      QROption(
        label: AppLocalizations.of(context)!.emailQR,
        svgData: AppAsset.emailIconSvg,
        type: QROptionType.email,
      ),
      // twitter
      QROption(
        label: AppLocalizations.of(context)!.twitterQR,
        svgData: AppAsset.twitterIconSvg,
        type: QROptionType.twitter,
      ),
      // instagram
      QROption(
        label: AppLocalizations.of(context)!.instagramQR,
        svgData: AppAsset.instagramIconSvg,
        type: QROptionType.instagram,
      ),
      // telephone
      QROption(
        label: AppLocalizations.of(context)!.telephoneQR,
        svgData: AppAsset.telephoneIconSvg,
        type: QROptionType.telephone,
      ),
    ];
  }
}

class QROptionCard extends StatelessWidget {
  final QROption option;

  const QROptionCard({super.key, required this.option});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Center(
          child: Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              border: Border.all(color: Color(0xffFDB623), width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            // child: Icon(option.icon, color: Color(0xffFDB623), size: 30),
            child: SvgPicture.asset(
              option.svgData,
              colorFilter: ColorFilter.mode(
                Color(0xffFDB623),
                BlendMode.srcIn,
              ),
              width: 40,
              height: 40,
            ),
          ),
        ),
        Positioned(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Color(0xffFDB623),
              border: Border.all(color: Color(0xffFDB623), width: 2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              option.label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w300,
                color: Color(0xff2D3047),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
