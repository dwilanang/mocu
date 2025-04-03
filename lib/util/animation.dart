import 'package:flutter/material.dart';

class AnimationUtils {
  static Map<String, dynamic> createAnimation({
    required TickerProvider vsync,
    required Duration duration,
    required double begin,
    required double end,
    VoidCallback? onCompleted,
  }) {
    AnimationController controller = AnimationController(
      vsync: vsync,
      duration: duration,
    );

    Animation<double> animation = Tween<double>(begin: begin, end: end).animate(controller)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          controller.reverse();
          if (onCompleted != null) {
            onCompleted();
          }
        }
      });

    return {
      'controller': controller,
      'animation': animation,
    };
  }

  static Map<String, dynamic> createAnimationRepeat({
    required TickerProvider vsync,
    required Duration duration,
    required double begin,
    required double end,
    bool? reverse
  }) {
    AnimationController controller = AnimationController(
      vsync: vsync,
      duration: duration,
    )..repeat(reverse: reverse ?? true);

    Animation<double> animation = Tween<double>(begin: begin, end: end).animate(controller);

    return {
      'controller': controller,
      'animation': animation,
    };
  }

  static Map<String, dynamic> createAnimationRepeatNoReverse({
    required TickerProvider vsync,
    required Duration duration,
    required double begin,
    required double end
  }) {
    AnimationController controller = AnimationController(
      vsync: vsync,
      duration: duration,
    )..repeat();

    Animation<double> animation = Tween<double>(begin: begin, end: end).animate(controller);

    return {
      'controller': controller,
      'animation': animation,
    };
  }
}