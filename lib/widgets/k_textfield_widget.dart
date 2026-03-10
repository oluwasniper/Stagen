import 'package:flutter/material.dart';

class KTextField extends StatelessWidget {
  final String labelText;
  final String hintText;
  final bool? autoFocus;
  final int? maxLines;
  final TextInputType keyboardType;
  final TextEditingController? controller;
  const KTextField({
    super.key,
    required this.labelText,
    required this.hintText,
    this.autoFocus,
    this.maxLines,
    this.keyboardType = TextInputType.text,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(labelText,
            style: TextStyle(
              color: Color(0xffD9D9D9),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            )),
        SizedBox(height: 10),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            fillColor: Color(0xFF333333).withValues(alpha: 0.80),
            filled: true,
            hintStyle: TextStyle(
              color: Color(0xffD9D9D9).withValues(alpha: 0.34),
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(
                width: 1,
                color: Color(0xffD9D9D9),
              ),
            ),
            contentPadding: EdgeInsets.only(
              left: 15,
              right: 15,
              bottom: 10,
            ),

            // add input border with all sides colored yellow
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(
                width: 1,
                color: Color(0xffD9D9D9),
              ),
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(
                width: 1,
                color: Color(0xffD9D9D9),
              ),
            ),
          ),
          style: TextStyle(
            color: Color(0xffD9D9D9),
            fontSize: 17,
            fontWeight: FontWeight.w500,
          ),
          maxLines: maxLines ?? 1,
          autofocus: autoFocus ?? false,
          cursorColor: Color(0xffD9D9D9),
          cursorOpacityAnimates: true,
          cursorRadius: Radius.circular(6),
          showCursor: true,
          scrollPhysics: BouncingScrollPhysics(),
          cursorWidth: 2,
          keyboardType: keyboardType,
        ),
      ],
    );
  }
}
