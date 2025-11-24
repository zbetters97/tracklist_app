import 'package:flutter/material.dart';
import 'package:tracklist_app/features/media/models/track_class.dart';
import 'package:tracklist_app/features/review/services/review_service.dart';
import 'package:tracklist_app/core/widgets/stars_widget.dart';

class TrackCardWidget extends StatefulWidget {
  final Track track;

  const TrackCardWidget({super.key, required this.track});

  @override
  State<TrackCardWidget> createState() => _TrackCardWidgetState();
}

class _TrackCardWidgetState extends State<TrackCardWidget> {
  Track get media => widget.track;
  double _rating = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchRating();
  }

  void _fetchRating() async {
    double fetchedRating = await getAvgRating(media.id);

    setState(() => _rating = fetchedRating);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(border: Border.all(color: Colors.white, width: 2)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8.0,
        children: [
          Text(
            "${widget.track.trackNumber}. ${widget.track.name}",
            style: TextStyle(color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
          StarRating(rating: _rating, isCentered: true),
        ],
      ),
    );
  }
}
