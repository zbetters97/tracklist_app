import 'package:tracklist_app/core/constants/constants.dart';

abstract class Media {
  final String id;
  final String name;
  final String image;
  final String spotify;

  Media({required this.id, required this.name, this.image = DEFAULT_MEDIA_IMG, required this.spotify});
}
