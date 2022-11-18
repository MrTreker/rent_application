import 'package:flutter/material.dart';

class CustomSnackBar {
  CustomSnackBar(BuildContext context, Widget content, Color currentColor) {
    final SnackBar snackBar = SnackBar(
        action: SnackBarAction(
          label: '',
          textColor: Colors.white,
          onPressed: () {
            // Some code to undo the change.
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
        backgroundColor: Color.fromARGB(255, 199, 16, 3),
        content: content,
        behavior: SnackBarBehavior.floating);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
