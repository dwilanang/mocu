import 'package:flutter/material.dart';
import 'package:mocu/widget/alert.dart';

void showAlertDialog(BuildContext context, String title, String buttonName, Widget content, ActionCallback callback, String subTitle) {
  Navigator.of(context).push(PageRouteBuilder(
    opaque: false,
    barrierColor: Colors.black.withOpacity(0.7), // Set the barrier color to a semi-transparent black
    pageBuilder: (BuildContext context, _, __) {
      return CustomAlertDialog(
        title: title,
        buttonName: buttonName,
        content: content,
        callback: callback,
        subTitle: subTitle,
      );
    },
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 0.1);
      const end = Offset.zero;
      const curve = Curves.easeInBack;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  ));
}

typedef ActionCallback = void Function();