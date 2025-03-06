 import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mocu/constant.dart';

class CustomAlertDialog extends StatelessWidget {
  final String title;
  final String buttonName;
  final Widget content;
  final VoidCallback callback;
  final String subTitle;

  const CustomAlertDialog({
    super.key,
    required this.title,
    required this.buttonName,
    required this.content,
    required this.callback,
    required this.subTitle,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return AlertDialog(
      content: SizedBox(
        height: screenHeight / 3,
        child: Stack(
          children: [
            SvgPicture.asset(
              "assets/images/bgitem.svg",
              fit: BoxFit.fill,
            ),
            Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: white,
                      fontFamily: fontFamilyDynaPuff,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  content,
                  const SizedBox(height: 10.0),
                  Text(
                    subTitle,
                    style: TextStyle(
                      color: white,
                      fontFamily: fontFamilyDynaPuff,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        GestureDetector(
          onTapDown: (_) {
            callback();
          },
          child: SvgPicture.asset(
            "assets/images/$buttonName.svg",
            width: 150,
            fit: BoxFit.contain,
          ),
        ),
      ],
      actionsAlignment: MainAxisAlignment.center,
      backgroundColor: Colors.transparent,
    );
  }
}