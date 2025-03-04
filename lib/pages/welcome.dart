import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mocu/constant.dart';

class Welcome extends StatefulWidget {
  const Welcome({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _WelcomeState createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {

  startSplashScreen() async {
    var duration = const Duration(seconds: 2);
    return Timer(duration, () {
      Navigator.pushNamed(context, '/games');
      // Navigator.of(context).pushReplacement(
          // MaterialPageRoute(builder: (context) => const Games()));
    });
  }

  @override
  void initState() {
    super.initState();

    startSplashScreen();
  }

  @override
  Widget build(BuildContext context) {
     return Scaffold(
        backgroundColor: skyBlue,
        body:  Center(
            child: Container()
            // Lottie.asset(
            //   'assets/animation/splash-screen.json',
            //   fit: BoxFit.fill
            // )
        )
     );
  }

}