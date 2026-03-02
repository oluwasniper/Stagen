// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class SettingsListTile extends StatelessWidget {
  final bool isSwitched;
  final String title;
  final String subtitle;
  final IconData iconData;
  final bool? showSwitch;
  final void Function()? onTap;
  final void Function(bool)? onSwitchChanged;
  const SettingsListTile({
    super.key,
    required this.isSwitched,
    required this.title,
    required this.subtitle,
    required this.iconData,
    this.showSwitch,
    this.onTap,
    this.onSwitchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: const Color(0xff333333),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
            fontFamily: "Inter", fontSize: 13, color: Color(0xffC3C7C7)),
      ),
      leading: Icon(
        iconData,
        color: const Color(0xffFDB623),
        size: 25,
      ),
      title: Text(title,
          style: const TextStyle(
              fontFamily: "Inter",
              color: Color(0xffE2E2E2),
              fontSize: 16,
              fontWeight: FontWeight.w400)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      trailing: showSwitch == false
          ? null
          : Switch.adaptive(
              value: isSwitched,
              onChanged: onSwitchChanged ??
                  (_) {
                    // no-op if no callback provided
                  },
              inactiveThumbColor: const Color(0xff333333),
              inactiveTrackColor: const Color(0xffffffff).withValues(alpha: 0.19),
              trackOutlineColor:
                  WidgetStateProperty.all(const Color(0xffFDB623)),
              activeThumbColor: const Color(0xffFDB623),
            ),
      onTap: onTap ??
          () {
            onSwitchChanged?.call(!isSwitched);
          },
    );
  }
}
