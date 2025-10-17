import 'package:flutter/material.dart';
import 'package:tracklist_app/data/classes/review_class.dart';
import 'package:tracklist_app/data/constants.dart';
import 'package:tracklist_app/views/pages/review/review_page.dart';
import 'package:tracklist_app/views/pages/media/widgets/media_review_widget.dart';

class MediaReviews extends StatelessWidget {
  const MediaReviews({super.key, required this.reviews, required this.isLoading});

  final List<Review> reviews;
  final bool isLoading;

  void sendToReviewPage(BuildContext context, Review review) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => ReviewPage(review: review)));
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator(color: PRIMARY_COLOR_DARK));
    }
    if (reviews.isEmpty) {
      return Text("No reviews found");
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        spacing: 12.0,
        children: [
          ...reviews.map((review) {
            return GestureDetector(
              onTap: () => sendToReviewPage(context, review),
              child: MediaReviewWidget(review: review),
            );
          }),
        ],
      ),
    );
  }
}
