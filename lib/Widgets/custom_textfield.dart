import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  TextEditingController? controller;
  double radius;
  Color? fillColor;
  Widget? prefixIcon;
  Widget? suffixIcon;
  double borderWidth;
  Color borderColor;
  Color focusBorderColor;
  String? hintText;
  TextStyle? hintStyle;
  TextStyle? style;
  TextInputType? keyboardType;
  bool obscureText;
  double? height;
  double? width;
  bool? enabled;
  TextAlign textAlign;
  int? maxLines;
  void Function(String)? onChanged;
  CustomTextField(
      {Key? key, 
      this.controller,
      this.radius = 10,
      this.hintText,
      this.fillColor,
      this.prefixIcon,
      this.suffixIcon,
      this.enabled,
      this.style,
      this.hintStyle,
      this.textAlign = TextAlign.start,
      this.height,
      this.width,
      this.keyboardType,
      this.obscureText = false,
      this.borderWidth = 1,
      this.borderColor = const Color(0xFF000000),
      this.focusBorderColor = const Color(0xFF000000), this.maxLines=1, this.onChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: TextField(
        controller: controller,
        textAlign: textAlign,
        enabled: enabled,
        maxLines: maxLines,
        onChanged: onChanged,
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: style,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radius),
              borderSide: BorderSide(color: borderColor, width: borderWidth)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radius),
              borderSide:
                  BorderSide(color: focusBorderColor, width: borderWidth)),
          fillColor: fillColor,
          filled: true,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          hintText: hintText,
          hintStyle: hintStyle,
        ),
      ),
    );
  }
}
