import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart' as flip_card;
import 'package:flip_card/flip_card_controller.dart';
import 'package:rive/rive.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:mocu/constant.dart';
import 'package:mocu/util/utils.dart';
import 'package:mocu/util/audio.dart';
import 'package:mocu/util/alert.dart';
import 'package:mocu/model/memory.dart';
import 'package:mocu/util/animation.dart';
import 'package:mocu/widget/sectiontop.dart';
import 'package:mocu/widget/sectionbottom.dart';
import 'package:mocu/widget/countdowncompleted.dart';

class Memory extends StatefulWidget {
  const Memory({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MemoryState createState() => _MemoryState();
}

class _MemoryState extends State<Memory> with TickerProviderStateMixin {
  final AudioUtils _audioUtils = AudioUtils();

  late final Map<dynamic, AnimationController> _animationController = {};
  late final Map<dynamic, Animation<double>> _animation = {};

  final Map<dynamic, dynamic> animation = {};

  final CountDownController _controllerCountDown = CountDownController();
  final CountDownController _controllerCountDownComplete = CountDownController();

  final List<FlipCardController> _flipCardController = [];

  Map<int, String> _itemMatch = {};
  
  final int _mainAxisCount = 3;
  int _levelPlay = 1;
  int _limitRePlay = 3;
  int _itemNotMatch = 0;

  bool _isIntro = false;
  bool _soundMode = true;
  bool _loadingStartLevel = false;

  final List<MemoryModel>  _itemsWidget = [];
  List<MemoryModel>  _itemFlipOpen = [];
  
  final Map<int, int> _limitPlayLevel = {1: 5, 2: 4, 3: 3, 4: 2};
  final Map<int, int> _limitPlay = {};
  final Map<int, String> _pointPlay = {};

  final Map<int, List<int>> _items = {
    1: [9, 2, 7, 2, 9, 7],
    2: [12, 1, 8, 1, 12, 8],
    3: [3, 6, 4, 6, 3, 4],
    4: [5, 11, 10, 10, 5, 11]
  };
 
  Widget _itemAnimationWidget(dynamic name) {
    return SizedBox(
      height: 150.0,
      child: RiveAnimation.asset(
        utilItemAnimationAssetName(name),
        fit: BoxFit.fitHeight,
      ),
    );
  }

  void _generateList(){
      _items[_levelPlay]!.shuffle(Random());

      int i = 0;
      for (var index in _items[_levelPlay]!) {
          
        _flipCardController.add(FlipCardController());

        _itemsWidget.add(MemoryModel(
          index: i,
          id: "item-$index",
          widget:  Stack(
            children: [
              Container(
                color: softBrownOpacity,
                width: double.infinity,
                height: double.infinity,
              ),
              Align(
                alignment: Alignment.bottomCenter, // Posisi di bawah tengah
                child: _itemAnimationWidget(index),
              ),
            ],
          ),
        ));
        i++;
      }
  }

  void _increaseLimitPlay() {
    if (_limitPlay[_levelPlay]! > 0) {
      setState(() {
        _limitPlay[_levelPlay] = _limitPlay[_levelPlay]! - 1;
      });
    }
  }

  void _setAttributePlay(int levelPlay) {
    _audioUtils.play('start');

    setState(() {
      _loadingStartLevel = false;
      _itemMatch = {};
      _levelPlay = levelPlay;
      _limitPlay[levelPlay] = _limitPlayLevel[levelPlay]!;
    });

    _generateList();

    _itemsWidget.shuffle(Random());
    dataColors.shuffle(Random());
  }

  void _setPointPlay(String result) {
    if (result != "0") {
      _pointPlay[_levelPlay] = result;
    }
  }

  void _increaseLimitRePlay() {
      setState(() {
        _limitRePlay--;
      });
  }
  
  void _restartPlay() {
    setState(() {
      // Reset daftar kartu yang cocok
      _itemMatch = {};

      // Reset daftar kartu yang sedang dibuka
      _itemFlipOpen = [];
    });

    _controllerCountDown.restart();

    _resetAllCards();

    _generateList();

    _itemsWidget.shuffle(Random());
    dataColors.shuffle(Random());
  }
  
  void _resetPlay() {
    setState(() {
      // Reset daftar kartu yang cocok
      _itemMatch = {};

      // Reset daftar kartu yang sedang dibuka
      _itemFlipOpen = [];
      _levelPlay = 1;
      _limitRePlay = 3;
      _limitPlay[_levelPlay] = 3;
    });

    _controllerCountDown.restart();

    _resetAllCards();

    _generateList();

    _itemsWidget.shuffle(Random());
    dataColors.shuffle(Random());
  }
  
  void _resetAllCards() {
    // Tutup semua kartu yang terbuka
    for (var item in _itemsWidget) {
      if (_flipCardController[item.index].state?.isFront == false) {
        _flipCardController[item.index].toggleCard();
      }
    }
  }

  void _gameOver(int levelPlay) {
    _audioUtils.play('lose');

    WidgetsBinding.instance.addPostFrameCallback((_) {
        showAlertDialog(
          context,
          title:  "Game Overr",
          buttonTitle: "Exit",
          content: SvgPicture.asset(
            utilItemImageAssetName('fail'),
            width: 100.0,
            fit: BoxFit.cover,
          ),
          callback: (v) {
            if (v == 'click') {
                Navigator.pop(context); // Tutup alert
                Navigator.pop(context); // Kembali ke halaman sebelumnya
            }
          },
        );

      });
  }

  Widget _sectionTop() {

      return SectionTop(limitPlay: _limitPlay[_levelPlay]!, levelPlay: _levelPlay, limitRePlay: _limitRePlay);
  }

  Widget _sectionBottom(){
    return SectionBottom(
          mainAxisCount: _mainAxisCount,
          animationController: _animationController,
          animation: _animation,
          controllerCountDown: _controllerCountDown,
          autoStartCountDown: true,
          durationCountDown: 25,
          isMatchComplete: _itemMatch.length == _mainAxisCount,
          isTimeUp: _limitPlay[_levelPlay]! > 0,
          isSoundMode: _soundMode,
          onResetTapDown: (){
            _audioUtils.play("click");
            _animationController['replay']!.forward();

            _restartPlay();
          },
          onResetTapCancel: (){
            _animationController['replay']!.reverse();
          },
          onSoundTapDown: (){
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
          onSoundTapCancel: (){
            _animationController['sound']!.reverse();
          },
          onTimeUp: (){
              _audioUtils.play('timeup');

              showAlertDialog(
                context,
                title: "Time UP!",
                subTitle: "Try Again",
                buttonTitle: "Continue",
                content: SvgPicture.asset(
                  utilItemImageAssetName('fail'),
                    width: 100.0,
                    fit: BoxFit.cover,
                  ),
                  callback: (v){
                    if (v == 'click') {
                      Navigator.pop(context);

                      if (_limitRePlay == 1){
                        _gameOver(_levelPlay);
                        return;
                      }

                      if (_limitPlay[_levelPlay] == 1){
                        setState(() {
                          _limitRePlay--;
                          _limitPlay[_levelPlay] = _limitPlayLevel[_levelPlay]!;
                        });
                        _controllerCountDown.restart();
                        return;
                      }
                        
                      _increaseLimitPlay();
                      _restartPlay();
                    }
                  }
                );
                
          },
          onTimeRun: (v){
            _setPointPlay(v);
              int limitPlay = _limitPlay[_levelPlay] ?? 0;
              if (limitPlay == 0) {
                _limitRePlay--;
                return;
              }
          },
        );
  }

  Widget _itemCard(int index){
    return Card(
        color: whiteOpacity,
        semanticContainer: true,
        clipBehavior: Clip.antiAliasWithSaveLayer,
          child: Container(
            color: dataColors[index],
            width: double.infinity,
            height: double.infinity,
            child: _itemsWidget.isNotEmpty ? _itemsWidget[index].widget : Container(),
          ),
      );
  }

  void _checkItemMatch(){
    if (_limitPlay[_levelPlay]! > 0) {
                        
        // Jika dua kartu sudah dibuka, periksa apakah cocok
      if (_itemFlipOpen.length == 2) {
          var indexOrigin = _itemFlipOpen[0].index;
          var idOrigin = _itemFlipOpen[0].id;

          if(_itemFlipOpen.length == 1){
              _itemMatch[indexOrigin] = idOrigin;
          }else if (_itemFlipOpen.length == 2) {
            var idDestination = _itemFlipOpen[1].id;
            var indexDestination = _itemFlipOpen[1].index;

            if (idOrigin == idDestination) {
                
                _itemMatch[indexDestination] = idDestination;

                // if (!done) _audio.soundOk();
                _audioUtils.play('ok');
            } else {
                // if (_countLimitTry == 0) return;

                _audioUtils.play('fail');
                _limitPlay[_levelPlay] = _limitPlay[_levelPlay]! - 1;
                
                Future.delayed(const Duration(milliseconds: 100), (){
                    // _itemFlipOpen.removeWhere((item) => item.index == indexDestination);
                    _flipCardController[indexOrigin].toggleCard();
                    _flipCardController[indexDestination].toggleCard();
                });
            }
            _itemFlipOpen = [];
          }
      }
    }
  }

  void  _checkLimit(){
    if (_limitPlay[_levelPlay]! == 0) {
         _controllerCountDown.pause();

      if (_limitRePlay == 1){
        _gameOver(_levelPlay);
        return;
      }

      if (_levelPlay == 3) {
        _audioUtils.play('lose');
      } else {
        _audioUtils.play('timeup');
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        showAlertDialog(
          context,
          title: "Playtime is Over",
          subTitle: "Try Again",
          buttonTitle:  "Continue",
          content: SvgPicture.asset(
              utilItemImageAssetName('fail'),
            width: 100.0,
            fit: BoxFit.cover,
          ),
          callback: (v) {
            if (v == 'click') {
                if (_levelPlay == 3) {
                  _levelPlay = 1;
                }
                _setAttributePlay(_levelPlay);
                _controllerCountDown.restart();
                Navigator.pop(context);
            }
          },
        );

      });
      return;
    }
  }

  @override
  void initState() {
    super.initState();

    _audioUtils.play('start');

    _limitPlay[_levelPlay] = _limitPlayLevel[_levelPlay]!;
    _generateList();

    dataColors.shuffle(Random());

    Future.delayed(const Duration(seconds: 2), (){
      setState(() {
        _isIntro = true;
      });
    });

    animation['replay'] = AnimationUtils.createAnimation(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      begin: 1.0,
      end: 1.2,
    );

    _animationController['replay'] = animation['replay']['controller'];
    _animation['replay'] = animation['replay']['animation'];

    animation['sound'] = AnimationUtils.createAnimation(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      begin: 1.0,
      end: 1.2,
    );

    _animationController['sound'] = animation['sound']['controller'];
    _animation['sound'] = animation['sound']['animation'];
  }

  @override
  void dispose() {
    _audioUtils.stopAll();
    _animationController['replay']!.dispose();
    _animationController['sound']!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    const crossAxisCount = 2; // 1 kolom
    // final itemWidth = screenWidth / crossAxisCount;
    // final itemHeight = screenHeight / _mainAxisCount;
    const increaseScreenHeight = 200;
    double sizeItem = (screenHeight - increaseScreenHeight) / _mainAxisCount;

    _checkItemMatch();

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context); // Kembali ke halaman sebelumnya
        
        return false;
      },
      child: Scaffold(
        extendBodyBehindAppBar: true, // Membuat body berada di belakang AppBar
        backgroundColor: softBrown,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: _sectionTop(),
          backgroundColor: Colors.transparent, // Latar belakang transparan
          elevation: 0, // Menghilangkan bayangan
        ),
        body: Stack(
          children: [
              SizedBox(
                height: double.infinity,
                width: double.infinity,
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SvgPicture.asset(
                    utilItemImageAssetName('bg$_levelPlay'),
                    width: screenWidth,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              SizedBox(
                height: double.infinity,
                width: double.infinity,
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SvgPicture.asset(
                    utilItemImageAssetName('bgoverlay'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisExtent: sizeItem,
                ),
                itemCount: crossAxisCount * _mainAxisCount,
                itemBuilder: (context, index) {
                  
                  if (_isIntro){
                      if (_itemMatch.isNotEmpty && _itemMatch[index] != null){
                          return _itemCard(index);
                      } 

                      return flip_card.FlipCard(
                        fill: flip_card.Fill.fillBack, // Fill the back side of the card to make in the same size as the front.
                        direction: flip_card.FlipDirection.HORIZONTAL, // default
                        side: flip_card.CardSide.FRONT, // The side to initially display.
                        controller: _flipCardController.isNotEmpty ? _flipCardController[index] : null,
                        front: Card(
                          color: whiteOpacity,
                          semanticContainer: true,
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          child: Container(
                              color: dataColors[index],
                              width: double.infinity,
                              height: double.infinity,
                              child: Center(
                                child: Text("$index",
                                  style: TextStyle(
                                    color: white,
                                    fontSize: 50.0,
                                    fontFamily: fontFamilyDynaPuff,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              ),
                            )
                          
                        ),
                        back: _itemCard(index),
                        onFlip: (){
                            _audioUtils.play('click');
                            _checkLimit();
                        },
                        onFlipDone: (isFlip){
                          setState(() {

                            if(!isFlip) return;

                            int flipLength = _itemFlipOpen.length;
                            if (flipLength <2) {
                              setState(() {
                                _itemFlipOpen.add(_itemsWidget[index]);
                            });
                            }
                          });
                        },
                        // autoFlipDuration: const Duration(seconds: 2), // The flip effect will work automatically after the 2 seconds
                    );
                  } else {
                      return _itemCard(index);
                  }
                }
              ),
          ],
        ),
          bottomSheet: _sectionBottom(),
      )
    );
  }
}