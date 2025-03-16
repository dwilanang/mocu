import 'dart:math' as math;

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

  late final Map<dynamic, AnimationController> _animationController = {};
  late final Map<dynamic, Animation<double>> _animation = {};

  late final Map<int, AnimationController> _animationControllerPlay = {};
  late final Map<int, Animation<double>> _animationPlay = {};

  final Map<dynamic, dynamic> animation = {};
  final  Map<int, dynamic> playAnimation = {};

  final List<Map<String, dynamic>> _listGame = [
      {'title': "Matching", 'page':'/matching'}, 
      {'title': "Yummy or Yucky", 'page':'/yummy-yucky'}, 
      {'title': "Memory", 'page':'/matching'}, 
      {'title': "Grouping", 'page':'/matching'}
  ];

  bool _soundMode = true;

  @override
  void initState() {
    super.initState();

    animation['character'] = AnimationUtils.createAnimationRepeat(
        vsync: this,
        duration: const Duration(seconds: 1),
        begin: 0.9, end: 1.0
    );
   
    _animationController['character'] = animation['character']['controller'];
    _animation['character'] = animation['character']['animation'];

    // _audioUtils.play("backsound", loop: true);

    animation['sound'] = AnimationUtils.createAnimation(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      begin: 1.0,
      end: 1.2,
    );

    _animationController['sound'] = animation['sound']['controller'];
    _animation['sound'] = animation['sound']['animation'];

    for (int i = 1; i <= 4; i++) {
      playAnimation[i] = AnimationUtils.createAnimation(
          vsync: this,
          duration: const Duration(milliseconds: 100),
          begin: 1.0,
          end: 1.2
        );

        _animationControllerPlay[i] = playAnimation[i]['controller'];
        _animationPlay[i] = playAnimation[i]['animation'];

        animation[i] = AnimationUtils.createAnimationRepeatNoReverse(
            vsync: this,
            duration: const Duration(seconds: 5),
            begin: 0.0, end: 3 * math.pi
        );

      _animationController[i] = animation[i]['controller'];
      _animation[i] = animation[i]['animation'];
    }

    
  }

  @override
  void dispose() {
    _audioUtils.stopAll();

    List<String> animations = ['character', 'sound'];
    for (String v in animations) {
      _animationController[v]!.dispose();
    }
    
    for (int i = 1; i <= 4; i++) {
      _animationControllerPlay[i]!.dispose();
      _animationController[i]!.dispose();
    }
    
    super.dispose();
  }

  Widget _sectionTop(){
    return Container(
        padding: EdgeInsets.all(16.0),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Container(),
            ),
            GestureDetector(
              onTapDown: (_) {
                  _audioUtils.play("click");
                  _animationController['sound']!.forward();
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
                _animationController['sound']!.reverse();
              },
              child: AnimatedBuilder(
                animation: _animation['sound']!,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _animation['sound']!.value,
                    child: child,
                  );
                },
                child: Card(
                  color: whiteOpacity, // Hitam transparan
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100), // Oval
                  ),
                  child: Icon(
                    _soundMode ? Icons.volume_up : Icons.volume_off, // Ikon rumah
                    size: 60.0, // Ukuran ikon
                    color: darkBrown, // Warna ikon
                  ),
                ),
              ),
            ),
          ],
        ),
    );
  }

  Widget _itemGame(int i, Map<String, dynamic> item){
    return GestureDetector(
        onTapDown: (_) {
            _animationControllerPlay[i]!.forward();

            Future.delayed(Duration(milliseconds: 250), (){
              if (mounted){
                Navigator.pushNamed(context, item['page']);
              }
            });
        },
        onTapUp: (_){
            _audioUtils.play("click");
        },
        onTapCancel: () {
          _animationControllerPlay[i]!.reverse();
        },
        child: AnimatedBuilder(
          animation:  _animationPlay[i]!,
          builder: (context, child) {
            return Transform.scale(
              scale:  _animationPlay[i]!.value,
              child: child,
            );
          },
          child:  Card(
            color: softBrownOpacity, // transparan
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0), // Oval
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, // Center vertically
                crossAxisAlignment: CrossAxisAlignment.center, // Center horizontally
                children: [
                  Text(
                    item['title'],
                    style: TextStyle(
                      color: white,
                      fontSize: 20.0,
                      fontFamily: fontFamilyDynaPuff,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  AnimatedBuilder(
                    animation: _animation[i]!,
                    builder: (context, child) {
                    
                      return ShaderMask(
                        shaderCallback: (bounds) {
                          return LinearGradient(
                            colors: [
                              Colors.brown.shade500.withOpacity(0.5),
                              Colors.brown.shade100.withOpacity(0.5),
                              Colors.brown.shade500.withOpacity(0.5),
                            ],
                            stops: [
                              0.0,
                              0.5 + 0.5 * math.sin(_animation[i]!.value),
                              1.0,
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ).createShader(bounds);
                        },
                        blendMode: BlendMode.srcATop,
                        child: Card(
                          color: brown,
                          margin: EdgeInsets.all(10.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100), // Oval
                          ),
                          child: SizedBox(
                              height: 50.0,
                              child: Center(
                                child: Text(
                                    "Play",
                                    style: TextStyle(
                                      color: white,
                                      fontSize: 20.0,
                                      fontFamily: fontFamilyDynaPuff,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
    );
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
        backgroundColor: softBrown,
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
              Padding(
                padding: EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, // Tengah vertikal
                  crossAxisAlignment: CrossAxisAlignment.center, // Tengah horizontal
                  children: [
                    _sectionTop(),

                    Flexible(
                        child: SizedBox(
                          width: screenWidth,
                          height: 200.0,
                          child: AnimatedBuilder(
                            animation: _animation['character']!,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _animation['character']!.value,
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
                    ),
                    Expanded(
                      child: GridView.count(
                          crossAxisCount: 2, // Jumlah kolom
                          childAspectRatio: 1.3, // Sesuaikan rasio tinggi
                          children: _listGame.asMap().entries.map((entry) {
                            int index = entry.key;
                            Map<String, dynamic> item = entry.value;
                            return _itemGame(index+1, item);
                          }).toList()
                        ),
                    )
                  ],
                ),
              )
              ,
                Consumer<ActionProvider>(
                  builder: (context, model, child) {
                    
                    // if(model.execAction["sound"] != null){
                    //     if (model.execAction["sound"]! == true){
                    //       _audioUtils.play("backsound", loop: true);
                    //       _audioUtils.setVolume("backsound", 0.3);
                    //     } else {
                    //       _audioUtils.stop("backsound");
                    //     }
                    // } else if(model.execAction["valume"] != null){
                    //     if (model.execAction["valume"] == true) {
                    //         _audioUtils.setVolume("backsound", 1.0);
                    //     }
                    // }

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