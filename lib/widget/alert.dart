 import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mocu/constant.dart';

class CustomAlertDialog extends StatelessWidget {
  final String? title;
  final String? buttonName;
  final String? buttonTitle;
  final Widget? content;
  final Function? callback;
  final String? subTitle;
  final String? bgItem;

  const CustomAlertDialog({
    super.key,
    this.title,
    this.content,
    this.callback,
    this.subTitle,
    this.buttonName,
    this.buttonTitle,
    this.bgItem
  });

  Widget _body(String? title, subTitle, Widget? content){
    return Center(
        child:Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
              title != null ? Text(
                title,
                style: TextStyle(
                  color: white,
                  fontSize: 15.0,
                  fontFamily: fontFamilyDynaPuff,
                ),
              ) : Container(),
              const SizedBox(height: 8.0),
              content ?? Container(),
              const SizedBox(height: 10.0),
              subTitle != null ? Text(
                subTitle,
                style: TextStyle(
                  color: white,
                  fontSize: 15.0,
                  fontFamily: fontFamilyDynaPuff,
                  // fontWeight: FontWeight.bold,
                ),
              ) : Container(),
            ],
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    String bgItemAsset = 'bgitem';
    if (bgItem != null) {
        bgItemAsset = bgItem ?? 'bgitem';
    }

    return (buttonName == null && buttonTitle == null) ? 
      AlertDialog(
        content: SizedBox(
          height: screenHeight / 3,
          child: content ?? Container()
        ),
        actionsAlignment: MainAxisAlignment.center,
        backgroundColor: Colors.transparent,
      )
      : 
      AlertDialog(
      content: SizedBox(
        height: screenHeight / 2,
        child: bgItem == null ? 
          Card(
              color: superLightBrown, // Hitam transparan
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10), // Oval
              ),
              child: _body(title, subTitle, content),
            )
              :
          Stack(
            children: [
             SvgPicture.asset(
                "assets/images/$bgItemAsset.svg",
                height: double.infinity,
                width: double.infinity,
              ),
              _body(title, subTitle, content),
            ],
          ),
      ),
      actions: [
        GestureDetector(
          onTapDown: (_) {
            if (callback != null) {
              callback!('click');
            }
          },
          child: buttonName != null ?
            SvgPicture.asset(
              "assets/images/$buttonName.svg",
              width: 150,
              fit: BoxFit.contain,
            )
          :
            Card(
              color: brown,
              margin: EdgeInsets.all(10.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100), // Oval
              ),
              child: SizedBox(
                  height: 50.0,
                  child: Center(
                    child: Text(
                        "$buttonTitle",
                        style: TextStyle(
                          color: white,
                          fontSize: 15.0,
                          fontFamily: fontFamilyDynaPuff,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
              ),
            ),
        )
      ],
      actionsAlignment: MainAxisAlignment.center,
      backgroundColor: Colors.transparent,
    );
  }
}