import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mocu/constant.dart';
import 'package:mocu/utils/audio.dart';

class Games extends StatefulWidget {
  const Games({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _GamesState createState() => _GamesState();
}

class _GamesState extends State<Games> with SingleTickerProviderStateMixin {
  final AudioUtils _audioUtils = AudioUtils();
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // _audioUtils.play("backsound", loop: true);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );

    _animation = Tween<double>(begin: 1.0, end: 1.2).animate(_animationController)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _animationController.reverse();
        }
      });
  }

  @override
  void dispose() {
    _audioUtils.stopAll();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    // double screenHeight = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        backgroundColor: skyBlue,
        body: SafeArea(
          child: Stack(
            children: [
              SizedBox(
                height: double.infinity,
                width: double.infinity,
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SvgPicture.asset(
                    "assets/images/background.svg",
                    fit: BoxFit.cover,
                  ),
                ),
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
                        fit: BoxFit.contain,
                      ),
                    ),
                    GestureDetector(
                      onTapDown: (_) {
                        _animationController.forward();
                        _audioUtils.play("click", onComplete: (){
                            // _audioUtils.stop("backsound");
                            // _audioUtils.setVolume("backsound", 0.3);
                            Navigator.pushNamed(context, '/matching');
                        });
                      },
                      onTapUp: (_) {
                      },
                      onTapCancel: () {
                        _animationController.reverse();
                      },
                      child: AnimatedBuilder(
                        animation: _animation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _animation.value,
                            child: child,
                          );
                        },
                        child: SvgPicture.asset(
                          "assets/images/matching/play.svg",
                          width: 100,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      )
    );
  }
}