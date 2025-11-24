import 'package:flutter/material.dart';
import 'package:tracklist_app/core/widgets/loading_icon.dart';
import 'package:tracklist_app/features/review/models/review_class.dart';
import 'package:tracklist_app/features/media/models/track_class.dart';
import 'package:tracklist_app/core/constants/constants.dart';
import 'package:tracklist_app/features/review/services/review_service.dart';
import 'package:tracklist_app/features/media/content/media_reviews_content.dart';

class TrackContent extends StatefulWidget {
  final Track track;

  const TrackContent({super.key, required this.track});

  @override
  State<TrackContent> createState() => _TrackContentState();
}

class _TrackContentState extends State<TrackContent> {
  bool _isLoading = true;
  List<Review> _reviews = [];

  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  void _fetchReviews() async {
    setState(() => _isLoading = true);

    List<Review> fetchedReviews = await getReviewsByMediaId(widget.track.id);

    setState(() {
      _reviews = fetchedReviews;
      _isLoading = false;
    });
  }

  void _switchTab(int index) {
    setState(() => _fetchReviews());
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [__buildTabs()]);
  }

  Widget __buildTabs() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [_buildTab(0, "Reviews")]),
          ),
          _isLoading ? LoadingIcon() : MediaReviews(reviews: _reviews),
        ],
      ),
    );
  }

  Widget _buildTab(int index, String title) {
    return GestureDetector(
      onTap: () => _switchTab(index),
      child: Column(
        spacing: 5.0,
        children: [
          Text(
            title,
            style: TextStyle(color: PRIMARY_COLOR, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Container(
            height: 5,
            width: 85,
            decoration: BoxDecoration(color: PRIMARY_COLOR, borderRadius: BorderRadius.circular(2)),
          ),
        ],
      ),
    );
  }
}
