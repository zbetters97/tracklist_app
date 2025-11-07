import 'package:flutter/material.dart';
import 'package:tracklist_app/core/utils/notifiers.dart';
import 'package:tracklist_app/core/widgets/empty_text.dart';
import 'package:tracklist_app/features/review/models/review_class.dart';
import 'package:tracklist_app/features/review/pages/review_page.dart';
import 'package:tracklist_app/features/review/widgets/review_media_card_widget.dart';

class MediaReviews extends StatefulWidget {
  final List<Review> reviews;

  const MediaReviews({super.key, required this.reviews});

  @override
  State<MediaReviews> createState() => _MediaReviewsState();
}

class _MediaReviewsState extends State<MediaReviews> {
  List<Review> reviews = [];

  @override
  void initState() {
    super.initState();
    ratingNotifier.addListener(onRatingsChanged);
    reviews = widget.reviews;
  }

  void onRatingsChanged() {
    if (!mounted) return;

    filterByStars(ratingNotifier.value);
  }

  void sendToReviewPage(BuildContext context, Review review) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => ReviewPage(reviewId: review.reviewId)));
  }

  void filterByStars(double stars) {
    if (!mounted) return;

    if (stars == 0.0) {
      setState(() => reviews = widget.reviews);
    } else {
      setState(() => reviews = widget.reviews.where((review) => review.rating == stars).toList());
    }
  }

  @override
  void dispose() {
    ratingNotifier.removeListener(onRatingsChanged);
    ratingNotifier.value = 0.0;
    reviews.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        spacing: 12.0,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Filter by",
                style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 12),
              buildStarsDropdown(),
            ],
          ),
          const Divider(color: Colors.grey),
          buildReviews(reviews),
        ],
      ),
    );
  }

  Widget buildStarsDropdown() {
    return ValueListenableBuilder(
      valueListenable: ratingNotifier,
      builder: (context, value, child) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(border: Border.all(color: Colors.white)),
          child: DropdownButton(
            items: [
              ...List.generate(11, (i) {
                double rating = 5 - (i * 0.5);
                return DropdownMenuItem(value: rating, child: Text(rating == 0.0 ? "All" : "$rating stars"));
              }),
            ],
            underline: SizedBox(),
            style: TextStyle(fontSize: 20),
            value: ratingNotifier.value,
            onChanged: (value) => {
              setState(() {
                ratingNotifier.value = value!.toDouble();
                filterByStars(ratingNotifier.value);
              }),
            },
          ),
        );
      },
    );
  }

  Widget buildReviews(List<Review> reviews) {
    if (reviews.isEmpty) {
      return EmptyText(message: "No reviews found!");
    }

    return Column(
      children: [
        ...reviews.map((review) {
          return GestureDetector(
            onTap: () => sendToReviewPage(context, review),
            child: ReviewMediaCardWidget(review: review),
          );
        }),
      ],
    );
  }
}
