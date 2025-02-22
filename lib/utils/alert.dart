import 'package:flutter/material.dart';

showAlertDialog(BuildContext context, String title, String titleButton, Widget content, ActionCallback callback) {

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    content: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
            Text(title,
              style: const TextStyle(
                  color: Colors.black,
                  fontSize: 25.0,
                  fontWeight: FontWeight.bold,
              ),
            ),
            content,
        ],
    ),
    actions: [
      TextButton(
        style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
          backgroundColor: MaterialStateProperty.all<Color>(Colors.black),
        ),
        // ignore: unnecessary_null_comparison
        onPressed: callback,
        child: Text(titleButton),
      ),
    ],
    backgroundColor: Colors.white,
  );
  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
    barrierDismissible : false
  );
}

typedef ActionCallback = void Function();