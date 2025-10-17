import 'package:tracklist_app/data/classes/media_class.dart';

class Track extends Media {
  final String artist;
  final String album;
  final int trackNumber;
  final String releaseDate;

  Track({
    required super.id,
    required super.name,
    required this.artist,
    required this.album,
    super.image,
    required this.trackNumber,
    required this.releaseDate,
    required super.spotify,
  });

  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      id: json['id'],
      name: json['name'],
      artist: json['artist'],
      album: json['album'],
      image: json['image'],
      trackNumber: json['track_number'],
      releaseDate: json['release_date'],
      spotify: json['spotify'],
    );
  }
}
