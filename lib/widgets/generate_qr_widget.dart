// create enum for qr options
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:revolutionary_stuff/utils/app_asset.dart';

import '../l10n/app_localizations.dart';
import '../utils/app_motion.dart';

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
  sms,
  telegram,
  linkedin,
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
        label: AppLocalizations.of(context).textQR,
        svgData: AppAsset.textIconSvg,
        type: QROptionType.text,
      ),
      QROption(
        label: AppLocalizations.of(context).websiteQR,
        svgData: AppAsset.websiteIconSvg,
        type: QROptionType.website,
      ),
      QROption(
        label: AppLocalizations.of(context).wifiQR,
        svgData: AppAsset.wifiIconSvg,
        type: QROptionType.wifi,
      ),
      // event
      QROption(
        label: AppLocalizations.of(context).eventQR,
        svgData: AppAsset.eventIconSvg,
        type: QROptionType.event,
      ),
      // contact
      QROption(
        label: AppLocalizations.of(context).contactQR,
        svgData: AppAsset.contactIconSvg,
        type: QROptionType.contact,
      ),
      // business
      QROption(
        label: AppLocalizations.of(context).businessQR,
        svgData: AppAsset.businessIconSvg,
        type: QROptionType.business,
      ),
      // location
      QROption(
        label: AppLocalizations.of(context).locationQR,
        svgData: AppAsset.locationIconSvg,
        type: QROptionType.location,
      ),
      // whatsapp
      QROption(
        label: AppLocalizations.of(context).whatsappQR,
        svgData: AppAsset.whatsappIconSvg,
        type: QROptionType.whatsapp,
      ),
      // email
      QROption(
        label: AppLocalizations.of(context).emailQR,
        svgData: AppAsset.emailIconSvg,
        type: QROptionType.email,
      ),
      // twitter
      QROption(
        label: AppLocalizations.of(context).twitterQR,
        svgData: AppAsset.twitterIconSvg,
        type: QROptionType.twitter,
      ),
      // instagram
      QROption(
        label: AppLocalizations.of(context).instagramQR,
        svgData: AppAsset.instagramIconSvg,
        type: QROptionType.instagram,
      ),
      // telephone
      QROption(
        label: AppLocalizations.of(context).telephoneQR,
        svgData: AppAsset.telephoneIconSvg,
        type: QROptionType.telephone,
      ),
      // sms
      QROption(
        label: AppLocalizations.of(context).smsQR,
        svgData: AppAsset.smsIconSvg,
        type: QROptionType.sms,
      ),
      // telegram
      QROption(
        label: AppLocalizations.of(context).telegramQR,
        svgData: AppAsset.telegramIconSvg,
        type: QROptionType.telegram,
      ),
      // linkedin
      QROption(
        label: AppLocalizations.of(context).linkedinQR,
        svgData: AppAsset.linkedinIconSvg,
        type: QROptionType.linkedin,
      ),
    ];
  }

  static QROption fromType(BuildContext context, QROptionType type) {
    return getOptions(context).firstWhere(
      (option) => option.type == type,
      orElse: () => QROption(
        label: AppLocalizations.of(context).textQR,
        svgData: AppAsset.textIconSvg,
        type: QROptionType.text,
      ),
    );
  }
}

class QROptionCard extends StatefulWidget {
  final QROption option;
  final VoidCallback? onTap;

  const QROptionCard({super.key, required this.option, this.onTap});

  @override
  State<QROptionCard> createState() => _QROptionCardState();
}

class _QROptionCardState extends State<QROptionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _pressScale;
  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 220),
    );
    _pressScale = Tween<double>(begin: 1.0, end: 0.91).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final motion = AppMotion.of(context);

    return GestureDetector(
      onTapDown: (_) {
        if (!motion.reduceMotion) {
          _pressController.forward();
        }
      },
      onTapUp: (_) {
        if (!motion.reduceMotion) {
          _pressController.reverse();
        }
      },
      onTapCancel: () {
        if (!motion.reduceMotion) {
          _pressController.reverse();
        }
      },
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _pressController,
        builder: (context, child) {
          return Transform.scale(
            scale: motion.reduceMotion ? 1.0 : _pressScale.value,
            child: child,
          );
        },
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xffFDB623).withValues(alpha: 0.85),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  color: const Color(0xffFDB623).withValues(alpha: 0.07),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xffFDB623).withValues(alpha: 0.12),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Hero(
                  tag: 'qr_icon_${widget.option.type.name}',
                  child: SvgPicture.asset(
                    widget.option.svgData,
                    colorFilter: const ColorFilter.mode(
                      Color(0xffFDB623),
                      BlendMode.srcIn,
                    ),
                    width: 36,
                    height: 36,
                  ),
                ),
              ),
            ),
            Positioned(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xffFDB623),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  widget.option.label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xff1A1A1A),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
