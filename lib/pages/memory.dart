import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
import 'package:mocu/widget/rating.dart';
import 'package:mocu/provider/action.dart';

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
  int _itemOK = 0;
  final int _maxLevel = 4;

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

  void _generateList(int levelPlay){
    _items[levelPlay]!.shuffle();

    _itemsWidget.clear();

    int i = 0;
    for (var index in _items[levelPlay]!) {
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
    setState(() {
      _isIntro = false;
      _itemOK = 0;
      _itemMatch = {};
      _itemFlipOpen = [];
      _levelPlay = levelPlay;
      _loadingStartLevel = false;
      _limitPlay[levelPlay] = _limitPlayLevel[levelPlay]!;
    });

    _generateList(levelPlay);

    _itemsWidget.shuffle();
    dataColors.shuffle();

    _audioUtils.play('start');

    Future.delayed(const Duration(seconds: 2), (){
      setState(() {
        _isIntro = true;
      });
    });
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

    _generateList(_levelPlay);

    _itemsWidget.shuffle();
    dataColors.shuffle();

    _resetAllCards();
  }
  
  void _resetPlay() {
    setState(() {
      // Reset daftar kartu yang cocok
      _itemMatch = {};

      // Reset daftar kartu yang sedang dibuka
      _itemFlipOpen = [];
      _levelPlay = 1;
      _limitRePlay = 3;
      _limitPlay[_levelPlay] = _limitPlayLevel[_levelPlay]!;
    });

    _initGame();
    _controllerCountDown.restart();
    _resetAllCards();
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

            _resetPlay();
          },
          onResetTapCancel: (){
            _animationController['replay']!.reverse();
          },
          onSoundTapDown: (){
            _audioUtils.play("click");
            _animationController['sound']!.forward();
            setState(() {
              _soundMode = !_soundMode;
              context.read<ActionProvider>().setExecAction("sound", _soundMode);
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

      if (_loadingStartLevel) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
              showAlertDialog(
                context,
                content: CountDownCompleted(
                  countDownAutoStart: true, 
                  durationCountDown: 4, 
                  controllerCountDown: _controllerCountDownComplete, 
                  onChange: (v){
                      if (v == '1'){
                          Navigator.pop(context); // Tutup dialog
                          
                          _controllerCountDownComplete.reset();
                          Future.delayed(Duration(seconds: 1), (){
                            int level = _levelPlay;
                            if (_levelPlay < _maxLevel) {
                              level++;
                            }
                            
                            _setAttributePlay(level);

                            _controllerCountDown.restart();
                            
                        });
                      }
                  }
                )
              );
          });
          return;
      }
      
      // Jika dua kartu sudah dibuka, periksa apakah cocok
      if (_itemFlipOpen.length == 2) {
         
          
          if (_itemFlipOpen.length == 2) {
            var indexOrigin = _itemFlipOpen[0].index;
            var idOrigin = _itemFlipOpen[0].id;

            var idDestination = _itemFlipOpen[1].id;
            var indexDestination = _itemFlipOpen[1].index;

            if (idOrigin == idDestination) {
                _itemOK++;
                _itemMatch[indexOrigin] = idOrigin;
                _itemMatch[indexDestination] = idDestination;

                _audioUtils.play('ok');
            } else {

                _audioUtils.play('fail');
                _limitPlay[_levelPlay] = _limitPlay[_levelPlay]! - 1;
                
                Future.delayed(const Duration(milliseconds: 100), (){
                    _itemFlipOpen.removeWhere((item) => item.index == indexOrigin);
                    _itemFlipOpen.removeWhere((item) => item.index == indexDestination);
                    _flipCardController[indexOrigin].toggleCard();
                    _flipCardController[indexDestination].toggleCard();
                });
            }
            _itemFlipOpen = [];
          }
      }
    }
  }

  void _itemMatchComplete() {
    if (!_loadingStartLevel && _itemFlipOpen.length == 1 && _itemOK == 2){
         _controllerCountDown.pause();

         WidgetsBinding.instance.addPostFrameCallback((_) {

           if (_levelPlay == _maxLevel) {
              _itemMatchDone();
              return;
           }

          _audioUtils.play('success');

          showAlertDialog(
            context,
            title: "Yeyyy!",
            subTitle: "Your Roarsome",
            buttonTitle: "Continue",
            content:  SvgPicture.asset(
                utilItemImageAssetName('complete'),
                width: 100.0,
                fit: BoxFit.cover,
              ),
            callback: (v) {
              if (v == 'click') {
                Navigator.pop(context); // Tutup dialog

                setState(() {
                  _loadingStartLevel = true;
                });
              }
            },
          );
        });
    }
  }

  void _itemMatchDone(){
      //Nilai Akhir = ( (K1 + K2 + K3) / 3 * 0.6 ) + ( (T1 + T2 + T3) / 3 * 0.4 )

      int totalPointSpeed = (int.parse(_pointPlay[1]!) + int.parse(_pointPlay[2]!) + int.parse(_pointPlay[3]!) + int.parse(_pointPlay[4]!));
      
      double totalCalculateSpeed = (totalPointSpeed / _maxLevel) * 0.6;

      int totalCalculateSpeedRound = totalCalculateSpeed.round();

      int totalPointAccuracy = (_limitPlay[1]! + _limitPlay[2]! + _limitPlay[3]! + _limitPlay[4]!);

      double totalCalculateAccuracy = (totalPointAccuracy / _maxLevel) * 0.4;

      int totalCalculateAccuracyRound = totalCalculateAccuracy.round();

      double rating = (totalCalculateSpeedRound + totalCalculateAccuracyRound)/2;

      int finalRating = utilPointStar(rating);

      if (finalRating >= 4){
        _audioUtils.play('great');
      } else {
        _audioUtils.play('completed');
      }

      showAlertDialog(
        context,
        bgitem: 'bgboard',
        title: "Roarsome!",
        buttonTitle: "Continue",
        content: StarRating(
            rating: finalRating, // Nilai rating yang ingin ditampilkan
            color: brown,
        ),
        callback: (v) {
          if (v == 'click') {
            _controllerCountDown.pause();

            Navigator.pop(context); // Tutup dialog
            Navigator.pop(context); // Kembali ke halaman sebelumnya
          }
        },
      );
  }

  void  _checkLimit(){
    if (_limitPlay[_levelPlay]! == 0) {
         _controllerCountDown.pause();

      if (_limitRePlay == 1){
        _gameOver(_levelPlay);
        return;
      }

      if (_levelPlay == _maxLevel) {
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
                if (_levelPlay == _maxLevel) {
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

  void _initGame() {
    Future.delayed(const Duration(seconds: 2), (){
      setState(() {
        _isIntro = true;
      });
    });

    dataColors.shuffle();

    _generateList(_levelPlay);

    _itemsWidget.shuffle();
  }

  @override
  void initState() {
    super.initState();

    _audioUtils.play('start');

    _limitPlay[_levelPlay] = _limitPlayLevel[_levelPlay]!;

    _initGame();

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
        backgroundColor: superLightBrown,
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
                                child: Text("?",
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

                            if(!isFlip) return;

                            _itemMatchComplete();

                            setState(() {
                                _itemFlipOpen.add(MemoryModel(
                                  index: index, 
                                  id: _itemsWidget[index].id, 
                                ));
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