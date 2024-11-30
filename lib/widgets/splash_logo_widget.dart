import 'package:flutter/material.dart';
import '../utils/app_asset.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SplashLogoWidget extends StatelessWidget {
  const SplashLogoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final iconSize = MediaQuery.sizeOf(context).width * 0.6;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(
            top: iconSize,
            right: (iconSize / 0.6) * 0.2,
            left: (iconSize / 0.6) * 0.2,
          ),
          child: Image.asset(
            AppAsset.icon,
            height: iconSize,
            width: iconSize,
            filterQuality: FilterQuality.high,
            semanticLabel: '${AppLocalizations.of(context)!.appName} App Icon',
          ),
        ),
      ],
    );
  }
}
