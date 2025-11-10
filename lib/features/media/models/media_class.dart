import 'package:flutter/material.dart';
import 'package:tracklist_app/core/constants/constants.dart';
import 'package:tracklist_app/features/media/models/album_class.dart';
import 'package:tracklist_app/features/media/models/track_class.dart';

abstract class Media {
  final String id;
  final String name;
  final String image;
  final String spotify;

  Media({required this.id, required this.name, this.image = DEFAULT_MEDIA_IMG, required this.spotify});

  Widget buildImage(double size) {
    return Image.network(image, width: size, height: size, fit: BoxFit.cover);
  }

  Widget buildName(String category, bool isCentered) {
    return Column(
      crossAxisAlignment: isCentered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: isCentered ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            buildIcon(category),
            Flexible(
              child: Text(
                name,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
          ],
        ),
        Text(getMediaArtist(category), style: TextStyle(color: Colors.grey, fontSize: 18)),
      ],
    );
  }

  Widget buildIcon(String category) {
    Icon mediaIcon = category == "artist"
        ? Icon(Icons.person, color: Colors.grey, size: 28)
        : category == "album"
        ? Icon(Icons.album, color: Colors.grey, size: 28)
        : Icon(Icons.music_note, color: Colors.grey, size: 28);

    return mediaIcon;
  }

  Widget buildNameSimple(String category, bool isCentered) {
    return Column(
      crossAxisAlignment: isCentered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: isCentered ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            Flexible(
              child: Text(
                name,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
          ],
        ),
        Text(getMediaArtist(category), style: TextStyle(color: Colors.grey, fontSize: 18)),
      ],
    );
  }

  String getMediaArtist(String category) {
    return category == "album"
        ? (this as Album).artist
        : category == "track"
        ? (this as Track).artist
        : "";
  }
}
