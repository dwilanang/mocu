import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mocu/constant.dart';

class Matching extends StatefulWidget {
  const Matching({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MatchingState createState() => _MatchingState();
}

class _MatchingState extends State<Matching> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

     return Scaffold(
        backgroundColor: skyBlue,
        body:  SafeArea(
            child:  Stack(
              children:
                [
                   SizedBox(
                      height: double.infinity,
                      width: double.infinity,
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child:  SvgPicture.asset(
                          "assets/images/background.svg",
                          fit: BoxFit.cover
                        )
                      )
                   ),
                  Padding( 
                    padding: const EdgeInsets.only(
                      top: 200.0,
                      left: 10.0,
                      right: 10.0,
                    ),
                    child: Center(
                          child: Column(
                            children: [
                              Text(
                                  "cocokan",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: fontFamilyDynaPuff,
                                      fontSize: 50,
                                      color: darkBrown,
                                    ),
                              ),
                              Text(
                                  "dinosaurus",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: fontFamilyDynaPuff,
                                      fontSize: 25,
                                      color: superLightBrown,
                                    ),
                              ),
                            ],
                        )
                      )
                  ),
                  Padding( 
                    padding: const EdgeInsets.only(
                      top: 250.0,
                      left: 10.0,
                      right: 10.0,
                    ),
                    child: Center(
                      child: GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/matching-play');
                          },
                          child: SizedBox(
                            width: 125.0,
                            height: 100.0,
                            child: SvgPicture.asset(
                                  "assets/images/matching/play.svg",
                                  fit: BoxFit.fill
                            ),
                          )
                        )
                    )
                  )
              ]
          )
        )
     );
  }

}

