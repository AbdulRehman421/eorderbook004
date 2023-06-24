import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final void Function()? onPressed;
  final Color? backgroundColor;
  final double? radius;
  final double width;
  final double height;
  final Widget child;
  const CustomButton(
      {Key? key, 
      required this.child,
      required this.onPressed,
      this.backgroundColor,
      this.radius,
      required this.width,
      required this.height}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius ?? 10),
          ),
          backgroundColor: backgroundColor,
          minimumSize: Size(width, height)),
      child: child,
    );
  }
}
