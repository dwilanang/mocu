import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rive/rive.dart';
import 'package:dotted_border/dotted_border.dart';

import 'package:mocu/constant.dart';
import 'package:mocu/helper/helper.dart';
import 'package:mocu/util/alert.dart';
import 'package:mocu/util/audio.dart';
import 'package:mocu/util/animation.dart';
import 'package:mocu/widget/rating.dart';
import 'package:mocu/widget/sectionbottom.dart';
import 'package:mocu/widget/sectiontop.dart';
import 'package:mocu/widget/countdowncompleted.dart';
import 'package:mocu/provider/action.dart';
import 'package:mocu/util/utils.dart';

class Matching extends StatefulWidget {
  const Matching({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MatchingState createState() => _MatchingState();
}

class _MatchingState extends State<Matching> with TickerProviderStateMixin {
  
  late final Map<dynamic, AnimationController> _animationController = {};
  late final Map<dynamic, Animation<double>> _animation = {};

  final Map<dynamic, dynamic> animation = {};

  final AudioUtils _audioUtils = AudioUtils();

  final Map<int, List<int>> _itemsLeft = {
    1: [9, 10, 3, 4],
    2: [5, 6, 7, 8],
    3: [11, 2, 12, 1]
  };

  final Map<int, List<int>> _itemsRight = {
    1: [4, 3, 10, 9],
    2: [8, 7, 6, 5],
    3: [2, 11, 12, 1]
  };

  Map<int, bool> _itemMatch = {};
  Map<int, bool> _itemDropToTarget = {};

  final Map<int, int> _limitPlayLevel = {1: 3, 2: 2, 3: 1};
  final Map<int, int> _limitPlay = {};
  final Map<int, String> _pointPlay = {};
  
  final CountDownController _controllerCountDown = CountDownController();
  final CountDownController _controllerCountDownComplete = CountDownController();

  // final bool _countDownAutoStart = true;
  // final int _durationCountDown = 25;

  final int _mainAxisCount = 4;
  int _levelPlay = 1;
  int _limitRePlay = 3;
  int _itemNotMatch = 0;

  bool _soundMode = true;
  bool _loadingStartLevel = false;
  
  @override
  void initState() {
    super.initState();

    _audioUtils.play('start');

    _limitPlay[_levelPlay] = _limitPlayLevel[_levelPlay]!;

    shuffleArrays(_itemsLeft[_levelPlay]!, _itemsRight[_levelPlay]!);

    animation['character'] = AnimationUtils.createAnimationRepeat(
        vsync: this,
        duration: const Duration(seconds: 1),
        begin: 0.9, end: 1.0
    );
   
    _animationController['character'] = animation['character']['controller'];
    _animation['character'] = animation['character']['animation'];

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
    _animationController['character']!.dispose();
    _animationController['replay']!.dispose();
    _animationController['sound']!.dispose();
    super.dispose();
  }

  Widget _itemAnimationBoxWidget(double itemWidth, itemHeight, Widget content, Color itemColor) {
    return Container(
      width: itemWidth,
      height: itemHeight,
      margin: const EdgeInsets.all(5.0),
      decoration: BoxDecoration(
        color: itemColor,
        shape: BoxShape.circle, // Bentuk bulat
      ),
      child: content,
    );
  }

  Widget _itemAnimationWidget(dynamic name) {
    return RiveAnimation.asset(
      utilItemAnimationAssetName(name),
      fit: BoxFit.fitHeight,
    );
  }

   Widget _itemImageWidget(dynamic name) {
    return SvgPicture.asset(
      utilItemImageAssetName("match/shadow/$name"),
      width: 120.0,
      fit: BoxFit.contain,
    );
  }

  Widget _emptyBoxWidget() {
    return const SizedBox(width: 0, height: 0);
  }

  Widget _itemTarget(int itemRight, double itemWidth, itemHeight){
    return _itemAnimationBoxWidget(itemWidth, itemHeight, 
        _itemMatch[itemRight] == true ? 
          _itemAnimationWidget(itemRight)
      : 
        Center(
          child: AnimatedBuilder(
            animation: _animation['character']!,
            builder: (context, child) {
              return Transform.scale(
                scale: _animation['character']!.value,
                child: child,
              );
            },
            child: _itemImageWidget(itemRight),
            ),
        ),
        _itemNotMatch == itemRight ? red : _itemDropToTarget[itemRight] ?? false ? softBrown : whiteOpacity
    );
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

  Widget _matchPlay(double screenWidth, screenHeight) {
    const crossAxisCount = 1; // 1 kolom
    final itemWidth = screenWidth / crossAxisCount;
    final itemHeight = screenHeight / _mainAxisCount;
    const increaseScreenHeight = 200;
    double sizeItem = (screenHeight - increaseScreenHeight) / _mainAxisCount;

    return Row(
        children: [
          Expanded(
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisExtent: sizeItem,
              ),
              itemCount: crossAxisCount * _mainAxisCount,
              itemBuilder: (context, index) {
              
                int itemLeft = _itemsLeft[_levelPlay]![index];

                return Draggable<int>(
                  // ignoringFeedbackPointer: _limitRePlay == 0 ? false : true,
                  data: itemLeft,
                  onDragStarted: () {
                    _audioUtils.play("click");
                  },
                  feedback: SizedBox(
                    width: sizeItem,
                    height: sizeItem,
                    child: _itemAnimationWidget(itemLeft),
                  ),
                  childWhenDragging: _itemAnimationBoxWidget(itemWidth, itemHeight, _emptyBoxWidget(), whiteOpacity),
                  child: _itemMatch[itemLeft] == true
                      ? _emptyBoxWidget()
                      : _itemAnimationBoxWidget(
                          itemWidth, itemHeight,
                         _itemAnimationWidget(itemLeft),
                          whiteOpacity
                        ),
                  onDragCompleted: () {
                    setState((){
                      if (_itemNotMatch > 0) {
                        Future.delayed(Duration(milliseconds: 500), (){
                            _itemNotMatch = 0;
                        });
                      }

                      _itemDropToTarget = {};
                    });
                  },
                  onDraggableCanceled: (a, b) {
                    setState(()=>_itemDropToTarget = {});
                  },
                );
              },
            ),
          ),
          Expanded(
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisExtent: (screenHeight - 200) / _mainAxisCount,
              ),
              itemCount: crossAxisCount * _mainAxisCount,
              itemBuilder: (context, index) {
                int itemRight = _itemsRight[_levelPlay]![index];

                return DragTarget<int>(
                  builder: (BuildContext context, List<dynamic> accepted, List<dynamic> rejected) {
                    return _itemDropToTarget[itemRight] ?? false ?
                      DottedBorder(
                        color: brown,
                        strokeWidth: 2.0,
                        borderType: BorderType.Circle,
                        child: _itemTarget(itemRight, itemWidth, itemHeight),
                      )
                      :
                      _itemTarget(itemRight, itemWidth, itemHeight);
                  },
                  onWillAcceptWithDetails: (details) {
                    int limitPlay = _limitPlay[_levelPlay] ?? 0;
                    if (limitPlay == 0) {
                      _increaseLimitRePlay();
                    }

                    if (_itemMatch[itemRight] == true) {
                      return false;
                    }

                    setState((){
                      _itemDropToTarget = {};
                      _itemDropToTarget[itemRight] = true;
                    });
                    return true;
                  },
                  onAcceptWithDetails: (details) {
                    var isMatch = details.data == itemRight;

                    if (isMatch) {
                      _audioUtils.play('ok');

                      setState(() {
                        _itemDropToTarget = {};
                        _itemMatch[details.data] = isMatch;
                      });
                    } else {
                      _audioUtils.play('fail');

                      setState(() {
                        _itemNotMatch = itemRight;
                      });
                      
                      _increaseLimitPlay();

                      _stopCoundDown();
                    }
                  },
                );
              },
            ),
          ),
        ],
      );
  }

  void _matchCompleted() {
    // const crossAxisCount = 1;
    // const increaseScreenHeight = 200;
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
                          if (_levelPlay < 3) {
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

      }else if (!_loadingStartLevel && _itemMatch.length == _mainAxisCount) {
        _controllerCountDown.pause();

     
        if (_levelPlay == 3) {
          //Nilai Akhir = ( (K1 + K2 + K3) / 3 * 0.6 ) + ( (T1 + T2 + T3) / 3 * 0.4 )

          int totalPointSpeed = (int.parse(_pointPlay[1]!) + int.parse(_pointPlay[2]!) + int.parse(_pointPlay[3]!));
          
          double totalCalculateSpeed = (totalPointSpeed / 3) * 0.6;

          int totalCalculateSpeedRound = totalCalculateSpeed.round();

          int totalPointAccuracy = (_limitPlay[1]! + _limitPlay[2]! + _limitPlay[3]!);

          double totalCalculateAccuracy = (totalPointAccuracy / 3) * 0.4;

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
                Navigator.pop(context); // Tutup dialog
                Navigator.pop(context); // Kembali ke halaman sebelumnya

                _resetPlay();
                _controllerCountDown.pause();
              }
            },
          );
          
        } else {
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
        }

        return;
      } 
    });
                  
    // return Expanded(
    //   child: GridView.builder(
    //     shrinkWrap: true,
    //     physics: const NeverScrollableScrollPhysics(),
    //     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    //       crossAxisCount: crossAxisCount,
    //       mainAxisExtent: (screenHeight - increaseScreenHeight) / _mainAxisCount,
    //     ),
    //     itemCount: crossAxisCount * _mainAxisCount,
    //     itemBuilder: (BuildContext context, int index) {
    //       int item = _itemsLeft[_levelPlay]![index];

    //       return Card(
    //         color: whiteOpacity, // Hitam transparan
    //         shape: RoundedRectangleBorder(
    //           borderRadius: BorderRadius.circular(100), // Oval
    //         ),
            
    //         child: _itemAnimationWidget(item)
    //       );
    //     },
    //   ),
    // );
  }

  void _stopCoundDown() {
    if (_limitPlay[_levelPlay] == 0) {
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

      shuffleArrays(_itemsLeft[levelPlay]!, _itemsRight[levelPlay]!);
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
      _itemMatch = {};
    });

    _controllerCountDown.restart();
  }
  void _resetPlay() {
    setState(() {
      _itemMatch = {};
      _levelPlay = 1;
      _limitRePlay = 3;
      _limitPlay[_levelPlay] = 3;
    });

    _controllerCountDown.restart();
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    if (_itemMatch.length == _mainAxisCount) {
      _matchCompleted();
    }

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
        body: SafeArea(
          child: Stack(
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
              Padding(
                padding: EdgeInsets.all(25.0),
                child: _matchPlay(screenWidth, screenHeight),
              ),
              // Consumer<ActionProvider>(
              //   builder: (context, model, child) {
              //     return SizedBox.shrink();
              //   },
              // ),
            ],
          ),
        ),
        bottomSheet: _sectionBottom(),
      ),
    );
  }
}