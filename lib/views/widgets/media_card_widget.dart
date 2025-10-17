import 'package:flutter/material.dart';
import 'package:tracklist_app/data/classes/media_class.dart';
import 'package:tracklist_app/services/review_service.dart';
import 'package:tracklist_app/views/widgets/stars_widget.dart';

class MediaCardWidget extends StatefulWidget {
  const MediaCardWidget({super.key, required this.media});

  final Media media;

  @override
  State<MediaCardWidget> createState() => _MediaCardWidgetState();
}

class _MediaCardWidgetState extends State<MediaCardWidget> {
  double rating = 0.0;

  @override
  void initState() {
    super.initState();
    fetchRating();
  }

  void fetchRating() async {
    double fetchedRating = await getAvgRating(widget.media.id);

    setState(() {
      rating = fetchedRating;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 275.0,
      padding: EdgeInsets.only(top: 5, bottom: 5),
      child: Card(
        color: Colors.white,
        shape: BoxBorder.all(),
        child: Padding(
          padding: EdgeInsetsGeometry.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  boxShadow: [BoxShadow(color: Colors.black.withAlpha(120), blurRadius: 8, offset: Offset(0, 4))],
                ),
                child: Image.network(widget.media.image, width: 250, height: 250, fit: BoxFit.cover),
              ),
              const SizedBox(height: 10.0),
              Text(
                widget.media.name,
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20.0),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10.0),
              buildStarRating(rating, isCentered: true),
            ],
          ),
        ),
      ),
    );
  }
}
