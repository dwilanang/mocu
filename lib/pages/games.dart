import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mocu/constant.dart';
import 'package:mocu/utils/audio.dart';
import 'package:mocu/utils/animation.dart';
import 'package:mocu/provider/action.dart';

class Games extends StatefulWidget {
  const Games({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _GamesState createState() => _GamesState();
}

class _GamesState extends State<Games> with TickerProviderStateMixin {

  final AudioUtils _audioUtils = AudioUtils();

  late final AnimationController _animationControllerGroupCharacter;
  late final AnimationController _animationControllerSound;
  late final AnimationController _animationControllerPlay;

  late final Animation<double> _animationGroupCharacter;
  late final Animation<double> _animationSound;
  late final Animation<double> _animationPlay;

  bool _soundMode = true;

  @override
  void initState() {
    super.initState();

    var groupCharacterAnimation = AnimationUtils.createAnimationRepeat(
      vsync: this,
      duration: const Duration(seconds: 1),
      begin: 0.9, end: 1.0
    );

    _animationControllerGroupCharacter = groupCharacterAnimation['controller'];
    _animationGroupCharacter = groupCharacterAnimation['animation'];

    _audioUtils.play("backsound", loop: true);

    var soundAnimation = AnimationUtils.createAnimation(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      begin: 1.0,
      end: 1.2,
    );

    _animationControllerSound = soundAnimation['controller'];
    _animationSound = soundAnimation['animation'];

    var playAnimation = AnimationUtils.createAnimation(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      begin: 1.0,
      end: 1.2
    );

    _animationControllerPlay = playAnimation['controller'];
    _animationPlay = playAnimation['animation'];
  }

  @override
  void dispose() {
    _audioUtils.stopAll();
    _animationControllerGroupCharacter.dispose();
    _animationControllerSound.dispose();
    _animationControllerPlay.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    double screenWidth = MediaQuery.of(context).size.width;
    // double screenHeight = MediaQuery.of.context).size.height;

    // _backSoundControll(context);

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
              Column(
                  mainAxisAlignment: MainAxisAlignment.center, // Tengah vertikal
                  crossAxisAlignment: CrossAxisAlignment.center, // Tengah horizontal
                  children: [
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: AnimatedBuilder(
                          animation: _animationGroupCharacter,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _animationGroupCharacter.value,
                              child: child,
                            );
                          },
                          child: SvgPicture.asset(
                            "assets/images/group-character.svg",
                            width: screenWidth,
                            fit: BoxFit.contain,
                          ),
                        ),
                    ),
                    GestureDetector(
                      onTapDown: (_) {
                          _audioUtils.play("click");
                          _animationControllerSound.forward();
                          setState(() {
                            _soundMode = !_soundMode;

                            if (_soundMode) {
                                _audioUtils.play("backsound", loop: true);
                            } else {
                                _audioUtils.stop("backsound");
                            }
                          });
                      },
                      onTapCancel: () {
                        _animationControllerSound.reverse();
                      },
                      child: AnimatedBuilder(
                        animation: _animationSound,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _animationSound.value,
                            child: child,
                          );
                        },
                        child: SvgPicture.asset(
                          _soundMode ? "assets/images/soundon.svg" : "assets/images/soundoff.svg",
                            width: 75,
                            fit: BoxFit.contain,
                          ),
                      ),
                    ),
                    SizedBox(
                        height: 50.0
                    ),
                    GestureDetector(
                      onTapDown: (_) {
                        _animationControllerPlay.forward();
                        _audioUtils.play("click", onComplete: (){
                            _audioUtils.setVolume("backsound", 0.3);
                            Navigator.pushNamed(context, '/matching');
                        });
                      },
                      onTapUp: (_) {
                      },
                      onTapCancel: () {
                        _animationControllerPlay.reverse();
                      },
                      child: AnimatedBuilder(
                        animation: _animationPlay,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _animationPlay.value,
                            child: child,
                          );
                        },
                        child: SvgPicture.asset(
                          "assets/images/play.svg",
                          width: 150,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
                Consumer<ActionProvider>(
                  builder: (context, model, child) {
                    
                    if(model.execAction["sound"] != null){
                        if (model.execAction["sound"]! == true){
                          _audioUtils.play("backsound", loop: true);
                          _audioUtils.setVolume("backsound", 0.3);
                        } else {
                          _audioUtils.stop("backsound");
                        }
                    } else if(model.execAction["valume"] != null){
                        if (model.execAction["valume"] == true) {
                            _audioUtils.setVolume("backsound", 1.0);
                        }
                    }

                    return SizedBox.shrink();
                  },
                ),
            ],
          ),
        ),
      )
    );
  }
}