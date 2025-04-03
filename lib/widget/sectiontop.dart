import 'package:flutter/material.dart';
import 'package:mocu/constant.dart';

class SectionTop extends StatelessWidget {
  final int limitPlay;
  final int levelPlay;
  final int limitRePlay;

  const SectionTop({
    super.key,
    required this.limitPlay,
    required this.levelPlay,
    required this.limitRePlay
  });

  @override
  Widget build(BuildContext context) {

  
    return SizedBox(
      width: double.infinity,
      height: 50.0,
      child: Row(
        children: [
          Flexible(
            child: Card(
              color: whiteOpacity, // Hitam transparan
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100), // Oval
              ),
              child: Center(
                child: Text(
                  "Level : $levelPlay",
                  style: TextStyle(
                    color: brown,
                    fontFamily: fontFamilyDynaPuff,
                    fontSize: 15.0,
                  ),
                ),
              ),
            ),
          ),
          Flexible(
            child: Card(
              color: whiteOpacity, // Hitam transparan
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100), // Oval
              ),
              child: Center(
                child: Text(
                  "Play : $limitPlay x",
                  style: TextStyle(
                    color: brown,
                    fontFamily: fontFamilyDynaPuff,
                    fontSize: 15.0,
                  ),
                ),
              ),
            ),
          ),
          Flexible(
            child: Card(
              color: whiteOpacity, // Hitam transparan
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100), // Oval
              ),
              child: Center(
                child: Text(
                  "Replay : $limitRePlay x",
                  style: TextStyle(
                    color: brown,
                    fontFamily: fontFamilyDynaPuff,
                    fontSize: 15.0,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}