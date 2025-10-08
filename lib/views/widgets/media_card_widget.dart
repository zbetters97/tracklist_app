import 'package:flutter/material.dart';
import 'package:tracklist_app/data/constants.dart';

class MediaCardWidget extends StatelessWidget {
  const MediaCardWidget({super.key, required this.name, required this.imageUrl});

  final String name;
  final String imageUrl;

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
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(120), // Opacity (0 - 255)
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: imageUrl == ""
                    ? Image.asset(DEFAULT_MEDIA_IMG)
                    : Image.network(imageUrl, width: 250, height: 250, fit: BoxFit.cover),
              ),
              SizedBox(height: 10.0),
              Text(
                name,
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
