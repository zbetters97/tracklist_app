import 'package:flutter/material.dart';
import 'package:tracklist_app/features/review/models/review_class.dart';
import 'package:tracklist_app/features/media/models/track_class.dart';
import 'package:tracklist_app/core/constants/constants.dart';
import 'package:tracklist_app/features/review/services/review_service.dart';
import 'package:tracklist_app/features/media/content/media_reviews_content.dart';

class TrackContent extends StatefulWidget {
  const TrackContent({super.key, required this.track});

  final Track track;

  @override
  State<TrackContent> createState() => _TrackContentState();
}

class _TrackContentState extends State<TrackContent> {
  bool isLoading = true;
  List<Review> reviews = [];

  @override
  void initState() {
    super.initState();
    fetchReviews();
  }

  void fetchReviews() async {
    setState(() => isLoading = true);

    List<Review> fetchedReviews = await getReviewsByMediaId(widget.track.id);

    setState(() {
      reviews = fetchedReviews;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [buildTabs()]);
  }

  Widget buildTabs() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [buildTab(0, "Reviews")]),
          ),
          isLoading
              ? Center(child: CircularProgressIndicator(color: PRIMARY_COLOR_DARK))
              : MediaReviews(reviews: reviews),
        ],
      ),
    );
  }

  Widget buildTab(int index, String title) {
    return GestureDetector(
      onTap: () => switchTab(index),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(color: PRIMARY_COLOR, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Container(
            height: 5,
            width: 85,
            decoration: BoxDecoration(color: PRIMARY_COLOR, borderRadius: BorderRadius.circular(2)),
          ),
        ],
      ),
    );
  }

  void switchTab(int index) {
    setState(() => fetchReviews());
  }
}
