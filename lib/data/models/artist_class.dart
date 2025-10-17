import 'package:tracklist_app/data/models/media_class.dart';

class Artist extends Media {
  Artist({required super.name, required super.id, super.image, required super.spotify});

  factory Artist.fromJson(Map<String, dynamic> json) {
    return Artist(name: json['name'], id: json['id'], image: json['image'], spotify: json['spotify']);
  }
}
