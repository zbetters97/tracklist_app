import 'package:tracklist_app/data/classes/media_class.dart';
import 'package:tracklist_app/data/constants.dart';

class Track extends Media {
  final String album;
  final String releaseDate;

  Track({
    required super.id,
    required super.name,
    required this.album,
    super.image,
    required this.releaseDate,
    required super.spotify,
  });

  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      id: json['id'],
      name: json['name'],
      album: json['album'],
      image: json['image'] ?? DEFAULT_MEDIA_IMG,
      releaseDate: json['release_date'],
      spotify: json['spotify'],
    );
  }
}
