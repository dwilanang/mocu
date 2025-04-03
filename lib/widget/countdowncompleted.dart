import 'package:flutter/material.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
export 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:mocu/constant.dart';

class CountDownCompleted extends StatelessWidget {
  final int durationCountDown;
  final bool countDownAutoStart;
  final CountDownController controllerCountDown;
  final void Function()? onComplete;
  final void Function(String result)? onChange;

  const CountDownCompleted({
    super.key,
    required this.countDownAutoStart,
    required this.durationCountDown,
    required this.controllerCountDown,
    this.onComplete,
    this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return CircularCountDownTimer(
        duration: 4,
        initialDuration: 0,
        controller: controllerCountDown,
        width: double.infinity,
        height: double.infinity,
        ringColor: brown,
        fillColor: white,
        backgroundColor: Colors.transparent,
        strokeWidth: 5.0,
        strokeCap: StrokeCap.round,
        textStyle: TextStyle(
          color: white,
          fontSize: 50.0,
          fontFamily: fontFamilyDynaPuff,
        ),
        textFormat: CountdownTextFormat.S,
        isReverse: true,
        isTimerTextShown: true,
        autoStart: true,
        onComplete: onComplete,
        onChange: onChange,
      );
  }
  
}