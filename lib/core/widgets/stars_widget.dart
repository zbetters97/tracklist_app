import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final double rating;
  final bool isCentered;

  const StarRating({super.key, required this.rating, this.isCentered = false});

  double get roundedRating => (rating * 2).round() / 2;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: isCentered ? MainAxisAlignment.center : MainAxisAlignment.start,
      children: List.generate(5, (i) {
        double ratingValue = i + 1;
        bool isHalf = roundedRating == ratingValue - 0.5;
        Color starColor = ratingValue <= roundedRating ? Colors.amber : Colors.grey;

        return Icon(isHalf ? Icons.star_half : Icons.star, color: isHalf ? Colors.amber : starColor, size: 30);
      }),
    );
  }
}
