import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// QR v40 can hold at most 2953 bytes in binary mode; this is the hard ceiling
// for any user-supplied QR field. Appwrite's `data` attribute is 4096 chars,
// so this also prevents writes that exceed the DB column limit.
const int _kQrInputMaxLength = 2953;

class KTextField extends StatelessWidget {
  final String labelText;
  final String hintText;
  final bool? autoFocus;
  final int? maxLines;
  /// Hard character limit enforced via [LengthLimitingTextInputFormatter].
  /// Defaults to [_kQrInputMaxLength] (2953). Pass a smaller value for fields
  /// that have their own stricter format constraints (e.g. phone numbers).
  final int maxLength;
  final TextInputType keyboardType;
  final TextEditingController? controller;
  const KTextField({
    super.key,
    required this.labelText,
    required this.hintText,
    this.autoFocus,
    this.maxLines,
    this.maxLength = _kQrInputMaxLength,
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
          inputFormatters: [LengthLimitingTextInputFormatter(maxLength)],
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
