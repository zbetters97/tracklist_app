import 'package:flutter/material.dart';
import 'package:tracklist_app/features/review/models/review_class.dart';

class ReviewMediaCardWidget extends StatelessWidget {
  final Review review;

  const ReviewMediaCardWidget({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4.0,
      children: [
        Row(spacing: 8.0, children: [review.user.buildProfileImage(24.0), buildReviewHeader()]),
        review.buildContent(18.0),
      ],
    );
  }

  Widget buildReviewHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            style: TextStyle(color: Colors.grey, fontSize: 16),
            children: [
              TextSpan(text: "Review by "),
              TextSpan(
                text: review.user.username,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        review.buildDateShort(14.0),
        review.buildStarRating(false),
      ],
    );
  }
}
