import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rive/rive.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';

import 'package:mocu/constant.dart';
import 'package:mocu/helper/helper.dart';
import 'package:mocu/utils/alert.dart';
import 'package:mocu/utils/audio.dart';

class Matching extends StatefulWidget {
  const Matching({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MatchingState createState() => _MatchingState();
}

class _MatchingState extends State<Matching> with SingleTickerProviderStateMixin {
  final Map<int, String> _pointPlay = {};

  final AudioUtils _audioUtils = AudioUtils();
  List<int> _itemsLeft = [], _itemsRight = [];
  Map<int, bool> _itemMatch = {};

  final Map<int, int> _limitPlayLevel = {1:3, 2:2, 3:1};

  final CountDownController _controllerCountDown = CountDownController();

  final bool _countDownAutoStart = true;
  final int _durationCountDown = 25;

  int _levelPlay = 1;
  int _limitPlay = 0;
  

  @override
  void initState() {
    super.initState();

    _itemsLeft = List<int>.generate(4, (i) => i + 1);
    _itemsRight = List<int>.generate(4, (i) => i + 1);

    shuffleArrays(_itemsLeft, _itemsRight);

    _limitPlay = _limitPlayLevel[_levelPlay]!;

    // _audioUtils.play("backsound", loop: true);
    // _audioUtils.setVolume("backsound", 0.3); // Set volume backsound to 30%

  }

  @override
  void dispose() {
    _audioUtils.stopAll();
    super.dispose();
  }

  String _itemImageAssetName(dynamic name) {
    return "assets/images/$name.svg";
  }

  String _itemAnimationAssetName(dynamic name) {
    return "assets/animation/$name.riv";
  }

  Widget _itemAnimationBoxWidget(double itemWidth, itemHeight, Widget content) {
    return Container(
      width: itemWidth,
      height: itemHeight,
      margin: const EdgeInsets.all(5.0),
      decoration: BoxDecoration(
        color: white,
        shape: BoxShape.circle, // Bentuk bulat
      ),
      child: content,
    );
  }

  Widget _itemAnimationWidget(dynamic name, double itemWidth, itemHeight) {
    return RiveAnimation.asset(
      _itemAnimationAssetName(name),
      fit: BoxFit.fitHeight,
    );
  }

  Widget _emptyBoxWidget() {
    return const SizedBox(width: 0, height: 0);
  }

  Widget _timerCountDownWidget(Function callback) {
    return CircularCountDownTimer(
      duration: _durationCountDown,
      initialDuration: 0,
      controller: _controllerCountDown,
      width: double.infinity,
      height: double.infinity,
      ringColor: darkBrown,
      fillColor: superLightBrown,
      backgroundColor: skyBlue,
      strokeWidth: 5.0,
      strokeCap: StrokeCap.round,
      textStyle: TextStyle(
        color: Colors.white,
        fontFamily: fontFamilyDynaPuff,
      ),
      textFormat: CountdownTextFormat.S,
      isReverse: true,
      isTimerTextShown: true,
      autoStart: _countDownAutoStart,
      onComplete: () {
        callback('complete');
      },
      onChange: (String timeStamp) {
        callback(timeStamp);
      },
    );
  }

  Widget _sectionTop(double screenWidth, bool isComplete) {
    return SizedBox(
      width: double.infinity,
      height: 65.0,
      child: Row(
        children: [
          Expanded(
            child: Container(
                width: screenWidth / 3,
                height: double.infinity,
                margin: const EdgeInsets.all(5.0),
                decoration: BoxDecoration(
                  color: skyBlue,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Center(
                  child: Text(
                    "Level : $_levelPlay",
                    style: TextStyle(
                      color: white,
                      fontFamily: fontFamilyDynaPuff,
                      fontSize: 25.0,
                    ),
                  ),
                ),
              )
          ),
          Expanded(
            child: SizedBox(
              width: screenWidth / 3,
              height: double.infinity,
            ),
          ),
          Expanded(
            child: Container(
              width: screenWidth / 3,
              height: double.infinity,
              decoration: BoxDecoration(
                color: skyBlue,
                borderRadius: BorderRadius.circular(100),
              ),
              padding: EdgeInsets.only(top: 5.0, bottom: 5.0, left: 10.0),
              margin: EdgeInsets.all(5.0),
              child: Row(
                children: [
                  Expanded(
                    child: Center(
                      child: Text(
                        "$_limitPlay x",
                        style: TextStyle(
                          color: white,
                          fontFamily: fontFamilyDynaPuff,
                          fontSize: 25.0,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: _timerCountDownWidget((String result) {
                      if (result == "complete") {
                          if (isComplete) {
                            return;
                          }

                          if (_limitPlay > 0) {
                            _audioUtils.play('timeup');

                            showAlertDialog(
                              context,
                              "Heeem Time UP, Try Again!",
                              'continue',
                              Center(
                                child: SvgPicture.asset(
                                  _itemImageAssetName('fail'),
                                  fit: BoxFit.cover,
                                )
                              ),
                              () {
                                _increaseLimitPlay();
                                _restartPlay();
                                Navigator.pop(context);
                              },
                            );
                          }
                      } else {
                          if (result != "0"){
                              _pointPlay[_levelPlay] = result;
                          }
                         
                          _stopCoundDown();
                      }
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _matchPlay(int mainAxisCount, double screenWidth, screenHeight) {
    const crossAxisCount = 1; // 1 kolom
    final itemWidth = screenWidth / crossAxisCount;
    final itemHeight = screenHeight / mainAxisCount;
    const increaseScreenHeight = 200;
    double sizeItem = (screenHeight - increaseScreenHeight) / mainAxisCount;

    return Flexible(
      child: Row(
        children: [
          Expanded(
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisExtent: sizeItem,
              ),
              itemCount: crossAxisCount * mainAxisCount,
              itemBuilder: (context, index) {
                int itemLeft = _itemsLeft[index];

                return Draggable<int>(
                  data: itemLeft,
                  onDragStarted: () {
                    _audioUtils.play("click");
                  },
                  feedback: SizedBox(
                    width: sizeItem,
                    height: sizeItem,
                    child: _itemAnimationWidget(itemLeft, itemWidth, itemHeight),
                  ),
                  childWhenDragging: _itemAnimationBoxWidget(itemWidth, itemHeight, _emptyBoxWidget()),
                  child: _itemMatch[itemLeft] == true
                      ? _emptyBoxWidget()
                      : _itemAnimationBoxWidget(
                          itemWidth, itemHeight,
                          Stack(
                            children: [
                              _itemAnimationWidget(itemLeft, itemWidth, itemHeight),
                              Text("$itemLeft")
                            ],
                          ),
                          
                        ),
                  onDragCompleted: () {},
                  onDraggableCanceled: (a, b) {},
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
                mainAxisExtent: (screenHeight - 200) / mainAxisCount,
              ),
              itemCount: crossAxisCount * mainAxisCount,
              itemBuilder: (context, index) {
                int itemRight = _itemsRight[index];

                String itemName = "$itemRight.1";
                if (_itemMatch[itemRight] == true) {
                  itemName = itemRight.toString();
                }
                return DragTarget<int>(
                  builder: (BuildContext context, List<dynamic> accepted, List<dynamic> rejected) {
                    return Container(
                      margin: const EdgeInsets.all(5.0),
                      decoration: BoxDecoration(
                        color: white,
                        shape: BoxShape.circle,
                      ),
                      child: _itemMatch[itemRight] == true
                          ? _itemAnimationWidget(itemRight, itemWidth, itemHeight)
                          : Stack(
                            children: [
                              _itemAnimationWidget(itemName, itemWidth, itemHeight),
                              Text(itemName)
                            ],
                          ),
                    );
                  },
                  onWillAcceptWithDetails: (details) {
                    if (_itemMatch[details.data] == true) {
                      return false;
                    }

                    return true;
                  },
                  onAcceptWithDetails: (details) {
                    var isMatch = details.data == itemRight;

                    if (isMatch) {
                      _audioUtils.play('ok');

                      setState(() {
                        _itemMatch[details.data] = isMatch;
                      });
                      
                       if (_itemMatch.length == mainAxisCount) {
                          _audioUtils.play('completed');
                       }
                    } else {
                      _audioUtils.play('fail');

                      showAlertDialog(
                        context,
                        "Upps Not Match, Try Again!",
                        'continue',
                        Center(
                          child: SvgPicture.asset(
                            _itemImageAssetName("no"),
                            fit: BoxFit.cover,
                          )
                        ),
                        () {
                          _increaseLimitPlay();
                          Navigator.pop(context);
                        },
                      );
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _matchCompleted(int mainAxisCount, double screenWidth, screenHeight) {
    const crossAxisCount = 1;
    final itemWidth = screenWidth / crossAxisCount;
    final itemHeight = screenHeight / mainAxisCount;
    const increaseScreenHeight = 200;

    if (_itemMatch.length == mainAxisCount) {    
      _controllerCountDown.pause();

      WidgetsBinding.instance.addPostFrameCallback((_) {
          
          if (_levelPlay == 3) {
              showAlertDialog(
                  context,
                  "Good Job!",
                  'continue',
                  Center(
                      child: Text(_pointPlay.toString())
                  ),
                  () {
                      Navigator.pushReplacementNamed(context, '/games');
                  },
              );
              return;
          }
          
          showAlertDialog(
              context,
              "Yeyyy, your Roarsome!",
              'continue',
              Center(
                  child: SvgPicture.asset(
                    _itemImageAssetName('ok'),
                    fit: BoxFit.cover,
                  )
              ),
              () {
                  Navigator.pop(context); // Tutup dialog
                  
                  int level = _levelPlay;
                  if (_levelPlay < 3) {
                    level++;  
                  }
                  
                  _controllerCountDown.restart();
                  _setAttributePlay(level);
              },
          );
      });                
    }

    return Flexible(
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisExtent: (screenHeight - increaseScreenHeight) / mainAxisCount,
        ),
        itemCount: crossAxisCount * mainAxisCount,
        itemBuilder: (BuildContext context, int index) {
          int item = _itemsLeft[index];

          return _itemAnimationWidget(item, itemWidth, itemHeight);
        },
      ),
    );
  }

  _increaseLimitPlay() {
    if (_limitPlay > 0) {
      setState(() {
        _limitPlay--;
      });
    }
  }

  _stopCoundDown() {
    if (_limitPlay == 0) {
      _audioUtils.play('timeup');

      _controllerCountDown.pause();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        showAlertDialog(
          context,
          "Uppps It's OK, Try Again!",
          'continue',
          Center(
              child: SvgPicture.asset(
                _itemImageAssetName('fail'),
                fit: BoxFit.cover,
              )
          ),
          () {
            if (_levelPlay == 3) {
              _levelPlay = 1;
            }
            _setAttributePlay(_levelPlay);
            _controllerCountDown.restart();
            Navigator.pop(context);
          },
        );
      });
    }
  }

  _setAttributePlay(int levelPlay) {
    setState(() {
      _itemMatch = {};
      _levelPlay = levelPlay;
      _limitPlay = _limitPlayLevel[levelPlay]!;

      shuffleArrays(_itemsLeft, _itemsRight);
    });
  }

  _restartPlay() {
    setState(() {
      _itemMatch = {};
    });

    _controllerCountDown.restart();
  }

  @override
  Widget build(BuildContext context) {
    
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    const mainAxisCount = 4;

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              SizedBox(
                height: double.infinity,
                width: double.infinity,
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SvgPicture.asset(
                    _itemImageAssetName('bg$_levelPlay'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Column(
                children: [
                  _sectionTop(screenWidth, _itemMatch.length == mainAxisCount),
                  _itemMatch.length == mainAxisCount
                      ? _matchCompleted(mainAxisCount, screenWidth, screenHeight)
                      : _matchPlay(mainAxisCount, screenWidth, screenHeight),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}