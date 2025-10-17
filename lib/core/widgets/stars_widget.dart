import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  StarRating({super.key, required this.rating, this.isCentered = false});

  final double rating;
  final bool isCentered;

  late final double roundedRating = (rating * 2).round() / 2;

  Color getStarColor(double ratingValue) {
    return ratingValue <= roundedRating ? Colors.amber : Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: isCentered ? MainAxisAlignment.center : MainAxisAlignment.start,
      children: List.generate(5, (i) {
        double ratingValue = i + 1;
        bool isHalf = roundedRating == ratingValue - 0.5;

        return Icon(
          isHalf ? Icons.star_half : Icons.star,
          color: isHalf ? Colors.amber : getStarColor(ratingValue),
          size: 30,
        );
      }),
    );
  }
}
