import 'package:flutter/material.dart';
import 'package:tracklist_app/features/media/models/album_class.dart';
import 'package:tracklist_app/features/media/models/artist_class.dart';
import 'package:tracklist_app/features/media/models/media_class.dart';

class MediaCardWidget extends StatefulWidget {
  final Media media;
  final Function onOpenMedia;

  const MediaCardWidget({super.key, required this.media, required this.onOpenMedia});

  @override
  State<MediaCardWidget> createState() => _MediaCardWidgetState();
}

class _MediaCardWidgetState extends State<MediaCardWidget> {
  Media get media => widget.media;

  @override
  Widget build(BuildContext context) {
    String category = media is Artist
        ? "artist"
        : media is Album
        ? "album"
        : "track";

    return GestureDetector(
      onTap: () => widget.onOpenMedia(media),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 5.0,
        children: [buildMediaImage(), media.buildNameSimple(category, true)],
      ),
    );
  }

  Widget buildMediaImage() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(120), blurRadius: 8, offset: Offset(0, 4))],
      ),
      child: media.buildImage(175.0),
    );
  }
}
