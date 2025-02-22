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

    double screenWidth = MediaQuery.of(context).size.width;
    // double screenHeight = MediaQuery.of(context).size.height;

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
                  Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center, // Tengah vertikal
                        crossAxisAlignment: CrossAxisAlignment.center, // Tengah horizontal
                        children: [
                          Padding(
                            padding: EdgeInsets.all(25.0),
                            child: SvgPicture.asset(
                                "assets/images/matching/group-character.svg",
                                width: screenWidth,
                                fit: BoxFit.contain
                              ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/matching-play');
                            },
                            child: SvgPicture.asset(
                                  "assets/images/matching/play.svg",
                                  width: 100,
                                  fit: BoxFit.contain
                                ),
                          )
                        ],
                    ),
                  )
              ]
          )
        )
     );
  }

}

