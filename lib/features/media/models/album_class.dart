import 'package:tracklist_app/features/media/models/media_class.dart';

class Album extends Media {
  final String artist;
  final String artistId;
  final String releaseDate;

  Album({
    required super.id,
    required super.name,
    required this.artist,
    required this.artistId,
    super.image,
    required this.releaseDate,
    required super.spotify,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      id: json['id'],
      name: json['name'],
      artist: json['artist'],
      artistId: json['artist_id'],
      image: json['image'],
      releaseDate: json['release_date'],
      spotify: json['spotify'],
    );
  }
}
