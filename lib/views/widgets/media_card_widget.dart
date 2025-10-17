import 'package:flutter/material.dart';
import 'package:tracklist_app/data/classes/media_class.dart';

class MediaCardWidget extends StatelessWidget {
  const MediaCardWidget({super.key, required this.media});

  final Media media;

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
                child: Image.network(media.image, width: 250, height: 250, fit: BoxFit.cover),
              ),
              SizedBox(height: 10.0),
              Text(
                media.name,
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
