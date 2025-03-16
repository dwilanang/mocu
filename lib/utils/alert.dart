import 'package:flutter/material.dart';
import 'package:mocu/widget/alert.dart';
import 'package:mocu/constant.dart';

void showAlertDialog(BuildContext context, {String? title, String? subTitle, String? bgitem, Widget? content, String? buttonName, String? buttonTitle, Function? callback}) {
  Navigator.of(context).push(PageRouteBuilder(
    opaque: false,
    barrierColor: blackOpacity, // Set the barrier color to a semi-transparent black
    pageBuilder: (BuildContext context, _, __) {
      if (callback != null) {
        callback('open');
      }
      
      return CustomAlertDialog(
        title: title,
        subTitle: subTitle,
        bgItem: bgitem,
        content: content,
        buttonName: buttonName,
        buttonTitle: buttonTitle,
        callback: callback,
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

// typedef ActionCallback = void Function();