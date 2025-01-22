import 'package:flutter/material.dart';
import 'package:revolutionary_stuff/widgets/background_screen_widget.dart';
import 'package:revolutionary_stuff/widgets/settings_list_tile.dart';

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
                "Settings",
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
                title: "Vibrate",
                subtitle: "Vibration when scan is done.",
              ),
              SizedBox(
                height: 20,
              ),
              SettingsListTile(
                iconData: Icons.notifications_active_outlined,
                isSwitched: false,
                title: "Beep",
                subtitle: "Beep when scan is done.",
              ),
              SizedBox(
                height: 50,
              ),
              Text(
                "Support",
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
                title: "Rate Us",
                subtitle: "Your best reward to us.",
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
                title: "Share",
                subtitle: "Share app with others.",
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
                title: "Privacy Policy",
                subtitle: "Follow our policies that benefits you.",
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
