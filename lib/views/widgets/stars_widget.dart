import 'package:flutter/material.dart';

Widget buildStarRating(double rating, {bool isCentered = false}) {
  double roundedRating = (rating * 2).round() / 2;

  Color getStarColor(double ratingValue) {
    return ratingValue <= roundedRating ? Colors.amber : Colors.grey;
  }

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
