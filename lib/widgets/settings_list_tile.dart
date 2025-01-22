// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class SettingsListTile extends StatefulWidget {
  bool isSwitched;
  final String title;
  final String subtitle;
  final IconData iconData;
  final bool? showSwitch;
  final void Function()? onTap;
  SettingsListTile({
    super.key,
    required this.isSwitched,
    required this.title,
    required this.subtitle,
    required this.iconData,
    this.showSwitch,
    this.onTap,
  });

  @override
  State<SettingsListTile> createState() => _SettingsListTileState();
}

class _SettingsListTileState extends State<SettingsListTile> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: Color(0xff333333),
      subtitle: Text(
        widget.subtitle,
        style: TextStyle(
            fontFamily: "Inter", fontSize: 13, color: Color(0xffC3C7C7)),
      ),
      leading: Icon(
        widget.iconData,
        color: Color(0xffFDB623),
        size: 25,
      ),
      title: Text(widget.title,
          style: TextStyle(
              fontFamily: "Inter",
              color: Color(0xffE2E2E2),
              fontSize: 16,
              fontWeight: FontWeight.w400)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      // show switch if showSwitch is true
      trailing: widget.showSwitch == false
          ? null
          : Switch.adaptive(
              value: widget.isSwitched,
              onChanged: (value) {
                setState(() {
                  widget.isSwitched = !widget.isSwitched;
                });
              },
              inactiveThumbColor: Color(0xff333333),
              inactiveTrackColor: Color(0xffffffff).withOpacity(0.19),
              trackOutlineColor: WidgetStateProperty.all(Color(0xffFDB623)),
              activeColor: Color(0xffFDB623),
            ),

      // use widget.onTap if it is not null and discard the widget.isSwitched
      onTap: widget.onTap ??
          () {
            setState(() {
              widget.isSwitched = !widget.isSwitched;
            });
          },
    );
  }
}
