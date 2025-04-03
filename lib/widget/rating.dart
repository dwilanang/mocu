import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final int rating;
  final int maxRating;
  final double size;
  final Color color;

  const StarRating({
    super.key,
    required this.rating,
    this.maxRating = 5,
    this.size = 20.0,
    this.color = Colors.amber,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxRating, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          size: size,
          color: color,
        );
      }),
    );
  }

  int getPointStar(double total) {
    if (total >= 0 && total < 2) {
      return 1;
    } else if (total >= 2 && total < 4) {
      return 2;
    } else if (total >= 4 && total < 6) {
      return 3;
    } else if (total >= 6 && total < 8) {
      return 4;
    } else if (total >= 8) {
      return 5;
    } else {
      return 0; // Nilai di luar rentang
    }
  }
}