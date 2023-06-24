import 'package:flutter/material.dart';

class Dialogs {
  static showCustomDialog(
      {required String title,
      required String description,
      required BuildContext context,
      required bool barrierDismissible}) {
    return showDialog(context: context, builder:(context) {
      return AlertDialog(
        title: Text(title),
        content: Text(description),
      );
    },);
  }
}
