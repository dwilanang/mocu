import 'dart:math';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rive/rive.dart';
import 'package:dotted_border/dotted_border.dart';

import 'package:mocu/constant.dart';
import 'package:mocu/util/animation.dart';
import 'package:mocu/util/audio.dart';
import 'package:mocu/util/alert.dart';
import 'package:mocu/util/utils.dart';
import 'package:mocu/widget/rating.dart';
import 'package:mocu/widget/sectionbottom.dart';
import 'package:mocu/widget/sectiontop.dart';
import 'package:mocu/widget/countdowncompleted.dart';
import 'package:mocu/provider/action.dart';

class Feeding extends StatefulWidget {
  const Feeding({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _FeedingState createState() => _FeedingState();
}

class _FeedingState extends State<Feeding> with TickerProviderStateMixin {

  final AudioUtils _audioUtils = AudioUtils();

  late final Map<dynamic, AnimationController> _animationController = {};
  late final Map<dynamic, Animation<double>> _animation = {};

  final Map<dynamic, dynamic> animation = {};

  final Map<int, int> _limitPlayLevel = {1: 3, 2: 2};
  final Map<int, int> _limitPlay = {};
  final Map<int, String> _pointPlay = {};
  
  Map<int, bool> _itemMatch = {};
  Map<int, bool> _itemDropToTarget = {};
  
  final int _mainAxisCount = 6;
  int _levelPlay = 1;
  int _limitRePlay = 3;
  int _itemNotMatch = 0;

  bool _soundMode = true;
  bool _isComplete = false;
  bool _loadingStartLevel = false;

  final CountDownController _controllerCountDown = CountDownController();
  final CountDownController _controllerCountDownComplete = CountDownController();

  final Map<int, List<Map<String, dynamic>>> _itemsTarget = {
    1: [ 
      {'character':7, 'eat':'2'}, 
      {'character':11, 'eat':'2,5'}, 
      {'character':6, 'eat':'7,8'}, 
      {'character':3, 'eat':'1,3'}, 
      {'character':10, 'eat':'1,3,9'}, 
      {'character':8, 'eat':'1,3,5,7'}
    ],
    2: [ 
      {'character':5, 'eat':'1,3,9'}, 
      {'character':1, 'eat':'2,5'}, 
      {'character':9, 'eat':'2,5'}, 
      {'character':2, 'eat':'3,4,6,9'}, 
      {'character':4, 'eat':'2,5'}, 
      {'character':12, 'eat':'1,3,4,6'}
      ],
  };

  final Map<int, List<int>> _itemsFood = {
    1: [6, 4, 1, 3, 5, 2, 7],
    2: [4, 2, 5, 1, 6, 3, 8],
  };

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Kunci ke portrait saat halaman ini dibuka
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    _limitPlay[_levelPlay] = _limitPlayLevel[_levelPlay]!;

    _itemsTarget[_levelPlay]!.shuffle(Random());
    _itemsFood[_levelPlay]!.shuffle(Random());

    _audioUtils.play('start');

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
    _animationController['character']!.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget _itemAnimationWidget(dynamic name) {
    return RiveAnimation.asset(
      utilItemAnimationAssetName(name),
      fit: BoxFit.fitHeight,
    );
  }

  Widget _itemFoodAsset(int foodId){
      return  SvgPicture.asset(
        utilItemImageAssetName('feeding/$foodId'),
        height: 125.0,
      );
  }
    
  Widget _itemFood(int foodId){
    return Card(
      color: whiteOpacity,
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: AnimatedBuilder(
          animation:  _animation['character']!,
          builder: (context, child) {
            return Transform.scale(
              scale: _animation['character']!.value,
              child: child,
            );
          },
          child: Padding(
            padding: EdgeInsets.all(10.0),
            child: _itemFoodAsset(foodId),
          ),
        ),
      )
    );
  }

  Widget _itemDrag(int foodId){
    return Draggable<int>(
        data: foodId,
        onDragStarted: () {
          _audioUtils.play("click");
        },
        feedback: Padding(
        padding: EdgeInsets.all(10.0),
        child: AnimatedBuilder(
          animation:  _animation['character']!,
          builder: (context, child) {
            return Transform.scale(
              scale: _animation['character']!.value,
              child: child,
            );
          },
          child: Padding(
            padding: EdgeInsets.all(10.0),
            child: _itemFoodAsset(foodId),
          ),
        ),
      ),
        childWhenDragging: _emptyBoxWidget(),
        child: _itemFood(foodId),
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
  }

  Widget _itemPlay(double screenWidth, screenHeight) {
    const crossAxisCount = 2; // 1 kolom
    final itemWidth = screenWidth / crossAxisCount;
    final itemHeight = screenHeight / _mainAxisCount;

    return Column(
      children: <Widget>[
        Expanded(
          flex: 4,
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount, // Sesuaikan jumlah kolom
              mainAxisExtent: (screenHeight / _mainAxisCount) + 25,
            ),
            itemCount: _mainAxisCount, // Sesuaikan jumlah item
            itemBuilder: (BuildContext context, int index) {
              var targetItem = _itemsTarget[_levelPlay]![index];

              return _itemTarget(itemWidth, itemHeight, targetItem);
            },
          ),
        ),
        Expanded(
          child: _isComplete
              ? _matchCompleted()
              : Row(
                  children: [
                    // Tombol Panah Kiri
                    // IconButton(
                    //   icon: Icon(Icons.arrow_left, size: 40.0, color: white),
                    //   onPressed: () {
                    //     _scrollController.animateTo(
                    //       _scrollController.offset - 100, // Geser ke kiri 100 piksel
                    //       duration: const Duration(milliseconds: 300),
                    //       curve: Curves.easeInOut,
                    //     );
                    //   },
                    // ),
                    // Daftar Makanan
                    // Expanded(
                    //    child: SingleChildScrollView(
                    //     controller: _scrollController,
                    //     scrollDirection: Axis.horizontal,
                    //     child: Row(
                    //       children: (_itemsFood[_levelPlay] as List<int>).map((foodId) {
                    //         return _itemDrag(foodId);
                    //       }).toList(),
                    //     ),
                    //   ),
                    // ),
                    // Tombol Panah Kanan
                    // IconButton(
                    //   icon: Icon(Icons.arrow_right, size: 40.0, color: white),
                    //   onPressed: () {
                    //     _scrollController.animateTo(
                    //       _scrollController.offset + 100, // Geser ke kanan 100 piksel
                    //       duration: const Duration(milliseconds: 300),
                    //       curve: Curves.easeInOut,
                    //     );
                    //   },
                    // ),
                  ],
                ),
        ),
        Expanded(
          child: SizedBox(
            height: 100.0,
          ),
        ),
      ],
    );
  }

  Widget _itemTarget(double itemWidth, itemHeight, Map<String, dynamic> targetItem){
    return DragTarget<int>(
          builder: (BuildContext context, List<dynamic> accepted, List<dynamic> rejected) {
            return _itemDropToTarget[targetItem['character']] ?? false ?
              DottedBorder(
                color: brown,
                strokeWidth: 2.0,
                borderType: BorderType.Circle,
                child: Center(
                  child: Container(
                    width: itemWidth,
                    height: itemHeight,
                    decoration: BoxDecoration(
                      color: whiteOpacity,
                      shape: BoxShape.circle, // Bentuk bulat
                    ),
                    child: _itemAnimationWidget(targetItem['character']),
                  ),
                ),
              )
              :
              Center(
                child: Container(
                  width: itemWidth,
                  height: itemHeight,
                  decoration: BoxDecoration(
                    color: _itemNotMatch == targetItem['character'] ? red : _itemMatch[targetItem['character']] ?? false ? green : whiteOpacity,
                    shape: BoxShape.circle, // Bentuk bulat
                  ),
                  child: _itemAnimationWidget(targetItem['character']),
                ),
              );
          },
          onWillAcceptWithDetails: (details) {

            if (_itemMatch[targetItem['character']] == true) {
              return false;
            }

            setState((){
              _itemDropToTarget = {};
              _itemDropToTarget[targetItem['character']] = true;
            });

            return true;
          },
          onAcceptWithDetails: (details) {
            var isMatch = targetItem['eat'].toString().contains(details.data.toString());

            if (isMatch) {
              _audioUtils.play('yummy');

              setState(() {
                _itemDropToTarget = {};
                _itemMatch[targetItem['character']] = isMatch;
              });

              if (_itemMatch.length == _mainAxisCount) {
                setState(() {
                  _isComplete = true;
                });

                _controllerCountDown.pause();
              }
            } else {
              _audioUtils.play('yucky');
              
              setState(() {
                _itemNotMatch = targetItem['character'];
              });

              Future.delayed(Duration(seconds: 2), (){
                  setState(() {
                    _itemNotMatch = 0;
                  });
              });

              _increaseLimitPlay();

              _stopCoundDown();
            }
          },
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
          durationCountDown: 40,
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
          },
        );
  }

  void _stopCoundDown() {
    if (_limitPlay[_levelPlay] == 0) {
      _controllerCountDown.pause();

      if (_limitRePlay == 1){
        _limitRePlay = 0;
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
                
                int limitPlay = _limitPlay[_levelPlay] ?? 0;
                if (limitPlay == 0) {
                  _limitRePlay--;
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

  Widget _emptyBoxWidget() {
    return const SizedBox(width: 0, height: 0);
  }

  Widget _matchCompleted() {

    if (!_loadingStartLevel && _itemMatch.length == _mainAxisCount) {
      _controllerCountDown.pause();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_levelPlay == 2) {
          //Nilai Akhir = ( (K1 + K2) / 2 * 0.6 ) + ( (T1 + T2) / 2 * 0.4 )

          int totalPointSpeed = (int.parse(_pointPlay[1]!) + int.parse(_pointPlay[2]!));
          
          double totalCalculateSpeed = (totalPointSpeed / 2) * 0.6;

          int totalCalculateSpeedRound = totalCalculateSpeed.round();

          int totalPointAccuracy = (_limitPlay[1]! + _limitPlay[2]!);

          double totalCalculateAccuracy = (totalPointAccuracy / 2) * 0.4;

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
                          
                          setState(() {
                            _isComplete = false;
                          });
                        });
                    }
                }
              )
            );
        });
    }

    return _emptyBoxWidget();
  }

  void _increaseLimitPlay() {
    if (_limitPlay[_levelPlay]! > 0) {
      setState(() {
        _limitPlay[_levelPlay] = _limitPlay[_levelPlay]! - 1;
      });
    }
  }

  void _setPointPlay(String result) {
    if (result != "0") {
      _pointPlay[_levelPlay] = result;
    }
  }

  void _restartPlay() {
    setState(() {
      _itemMatch = {};
    });

    _controllerCountDown.restart();
  }

  void _setAttributePlay(int levelPlay) {
    _audioUtils.play('start');

    setState(() {
      _loadingStartLevel = false;
      _itemMatch = {};
      _levelPlay = levelPlay;
      _limitPlay[levelPlay] = _limitPlayLevel[levelPlay]!;

      _itemsTarget[_levelPlay]!.shuffle(Random());
    });
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

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
                    utilItemImageAssetName('feeding/bg$_levelPlay'),
                    width: screenWidth,
                  ),
                ),
              ),
              // SizedBox(
              //   height: double.infinity,
              //   width: double.infinity,
              //   child: FittedBox(
              //     fit: BoxFit.cover,
              //     child: SvgPicture.asset(
              //       utilItemImageAssetName('bgoverlay'),
              //       fit: BoxFit.cover,
              //     ),
              //   ),
              // ),
              
              _itemPlay(screenWidth, screenHeight)
            ],
          )
        ),
        // bottomSheet: _sectionBottom(),
      ),
    );
  }
}