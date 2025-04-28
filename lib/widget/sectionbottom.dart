import 'package:mocu/constant.dart';
import 'package:flutter/material.dart';
import 'package:mocu/widget/countdownplay.dart';

class SectionBottom extends StatelessWidget {
  final int? mainAxisCount;
  final Map<dynamic, AnimationController>? animationController;
  final Map<dynamic, Animation<double>>? animation;
  final CountDownController? controllerCountDown;
  final int? durationCountDown;
  final bool? autoStartCountDown;
  final bool? isMatchComplete;
  final bool? isTimeUp;
  final bool? isSoundMode;
  final void Function()? onResetTapDown;
  final void Function()? onResetTapCancel;
  final void Function()? onSoundTapDown;
  final void Function()? onSoundTapCancel;
  final void Function(String result)? onTimeRun;
  final void Function()? onTimeUp;
    
  const SectionBottom({
    super.key,
    this.mainAxisCount,
    this.animationController,
    this.animation,
    this.controllerCountDown,
    this.durationCountDown,
    this.autoStartCountDown,
    this.isMatchComplete,
    this.isTimeUp,
    this.isSoundMode,
    this.onResetTapDown,
    this.onResetTapCancel,
    this.onSoundTapDown,
    this.onSoundTapCancel,
    this.onTimeRun,
    this.onTimeUp
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 100.0, // Tinggi BottomSheet
        color:superLightBrown,
        padding: EdgeInsets.all(5.0),
        child: Row(
          children: [
            onResetTapDown != null ?
              Expanded(
                child: Center(
                  child: GestureDetector(
                      onTapDown: (_){
                          onResetTapDown!();
                      },
                      onTapCancel: onResetTapCancel,
                      child: AnimatedBuilder(
                        animation: animation!['replay']!,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: animation!['replay']!.value,
                            child: child,
                          );
                        },
                        child: Card(
                          color: white, // Hitam transparan
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100), // Oval
                          ),
                          child: Icon(
                            Icons.refresh, // Ikon rumah
                            size: 40.0, // Ukuran ikon
                            color: darkBrown, // Warna ikon
                          ),
                        ),
                      ),
                  ),
                ),
              ) 
            : Container(),

            (durationCountDown != null &&  durationCountDown! > 0) ?
              Expanded(
                child: CountDownPlay(
                  countDownAutoStart: autoStartCountDown!,
                  durationCountDown: durationCountDown!,
                  controllerCountDown: controllerCountDown!,
                  onChange: onTimeRun,
                  onComplete: (){
                    if (isMatchComplete!) {
                      return;
                    }
                    
                    if (isTimeUp!) {
                      onTimeUp!();
                    }
                  }
                ),
              ) 
            : Container(),

            onSoundTapDown != null ?
              Expanded(
                child: Center(
                  child: GestureDetector(
                      onTapDown: (_) {
                        onSoundTapDown!();
                      },
                      onTapCancel: onSoundTapCancel,
                      child: AnimatedBuilder(
                        animation: animation!['sound']!,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: animation!['sound']!.value,
                            child: child,
                          );
                        },
                        child: Card(
                          color: white, // Hitam transparan
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100), // Oval
                          ),
                          child: Icon(
                            isSoundMode! ? Icons.volume_up : Icons.volume_off, // Ikon rumah
                            size: 40.0, // Ukuran ikon
                            color: darkBrown, // Warna ikon
                          ),
                        ),
                      ),
                    ),
                  ),
              )
            : Container(),
          ],
        )
      );
  }

}