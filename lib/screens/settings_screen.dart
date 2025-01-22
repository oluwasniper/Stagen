import 'package:flutter/material.dart';
import 'package:revolutionary_stuff/widgets/background_screen_widget.dart';
import 'package:revolutionary_stuff/widgets/settings_list_tile.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return BackgroundScreenWidget(
        screenTitle: "",
        body: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 30,
          ),
          child: ListView(
            physics: BouncingScrollPhysics(),
            children: [
              Text(
                AppLocalizations.of(context)!.settings,
                style: TextStyle(
                    color: Color(0xffFDB623),
                    fontSize: 26,
                    fontWeight: FontWeight.w400),
              ),
              SizedBox(
                height: 20,
              ),
              SettingsListTile(
                isSwitched: false,
                iconData: Icons.vibration_rounded,
                title: AppLocalizations.of(context)!.vibrate,
                subtitle: AppLocalizations.of(context)!.vibrateDesc,
              ),
              SizedBox(
                height: 20,
              ),
              SettingsListTile(
                iconData: Icons.notifications_active_outlined,
                isSwitched: false,
                title: AppLocalizations.of(context)!.beep,
                subtitle: AppLocalizations.of(context)!.beepDesc,
              ),
              SizedBox(
                height: 50,
              ),
              Text(
                AppLocalizations.of(context)!.support,
                style: TextStyle(
                    color: Color(0xffFDB623),
                    fontSize: 26,
                    fontWeight: FontWeight.w400),
              ),
              SizedBox(
                height: 20,
              ),
              SettingsListTile(
                isSwitched: false,
                showSwitch: false,
                title: AppLocalizations.of(context)!.rateUs,
                subtitle: AppLocalizations.of(context)!.rateUsDesc,
                iconData: Icons.check_circle_rounded,
                onTap: () {
                  // TODO: implement rate app
                  // rate app
                },
              ),
              SizedBox(
                height: 20,
              ),
              SettingsListTile(
                isSwitched: false,
                showSwitch: false,
                title: AppLocalizations.of(context)!.share,
                subtitle: AppLocalizations.of(context)!.shareDesc,
                iconData: Icons.share_rounded,
                onTap: () {
                  // TODO: implement share app
                  // share app
                },
              ),
              SizedBox(
                height: 20,
              ),
              // privacy policy
              SettingsListTile(
                isSwitched: false,
                showSwitch: false,
                title: AppLocalizations.of(context)!.privacyPolicy,
                subtitle: AppLocalizations.of(context)!.privacyPolicyDesc,
                iconData: Icons.privacy_tip_rounded,
                onTap: () {
                  // TODO: implement privacy policy
                },
              ),
            ],
          ),
        ));
  }
}
