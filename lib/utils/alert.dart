import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

void showAlertDialog(BuildContext context, String title, String buttonName, Widget content, ActionCallback callback) {
  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    content: Stack(
      children: [
          SvgPicture.asset(
            "assets/images/bgitem.svg",
            fit: BoxFit.cover,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 25.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content,
            ],
        )
      ],
    ),
    actions: [
      
      GestureDetector(
        onTapDown: (_) {
            callback();
        },
        child: SvgPicture.asset(
          "assets/images/$buttonName.svg",
          width: 100,
          fit: BoxFit.contain,
        ),
      ),
    ],
    actionsAlignment:MainAxisAlignment.center,
    backgroundColor: Colors.white,
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
    barrierDismissible: false,
  );
}

typedef ActionCallback = void Function();