import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RatingBar extends StatefulWidget {
  const RatingBar({super.key, required this.ratings});

  final QuerySnapshot ratings;

  @override
  State<RatingBar> createState() => _RatingBarState();
}

class _RatingBarState extends State<RatingBar> {
  late Map<double, int> ratings;
  int totalRatings = 0;

  @override
  void initState() {
    super.initState();
    setRatings();
  }

  void setRatings() {
    Map<double, int> baseRatings = {0.5: 0, 1: 0, 1.5: 0, 2: 0, 2.5: 0, 3: 0, 3.5: 0, 4: 0, 4.5: 0, 5: 0};
    totalRatings = widget.ratings.size;

    for (DocumentSnapshot doc in widget.ratings.docs) {
      double rating = doc["rating"].toDouble();
      baseRatings[rating] = baseRatings[rating]! + 1;
    }

    setState(() {
      ratings = baseRatings;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (ratings.isEmpty) {
      return Container();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      spacing: 2,
      children: ratings.keys.map((rating) {
        final int count = ratings[rating] ?? 0;

        // Minimum of 5%, maximum of 100%
        final double percentage = totalRatings == 0 ? 0.05 : (count / totalRatings).clamp(0.05, 1.0);

        return Tooltip(
          message: "$count ratings",
          child: Container(width: 24, height: 75 * percentage, color: Colors.grey),
        );
      }).toList(),
    );
  }
}
