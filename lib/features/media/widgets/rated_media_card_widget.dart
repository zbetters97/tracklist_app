import 'package:flutter/material.dart';
import 'package:tracklist_app/features/media/models/media_class.dart';
import 'package:tracklist_app/features/review/services/review_service.dart';
import 'package:tracklist_app/core/widgets/stars_widget.dart';

class RatedMediaCardWidget extends StatefulWidget {
  final Media media;

  const RatedMediaCardWidget({super.key, required this.media});

  @override
  State<RatedMediaCardWidget> createState() => _RatedMediaCardWidgetState();
}

class _RatedMediaCardWidgetState extends State<RatedMediaCardWidget> {
  Media get media => widget.media;
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
      width: 300.0,
      padding: EdgeInsets.only(top: 5, bottom: 5),
      child: Card(
        color: Colors.white,
        shape: BoxBorder.all(),
        child: Padding(
          padding: EdgeInsetsGeometry.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 10.0,
            children: [
              _buildMediaImage(media.image),
              _buildMediaName(media.name),
              StarRating(rating: _rating, isCentered: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMediaImage(String imageUrl) {
    Image mediaImage = imageUrl.startsWith("http")
        ? Image.network(imageUrl, width: 275, height: 275, fit: BoxFit.cover)
        : Image.asset(imageUrl, width: 275, height: 275, fit: BoxFit.cover);

    return Container(
      decoration: BoxDecoration(
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(120), blurRadius: 8, offset: Offset(0, 4))],
      ),
      child: mediaImage,
    );
  }

  Widget _buildMediaName(String name) {
    return Text(
      name,
      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20.0),
      textAlign: TextAlign.center,
    );
  }
}
