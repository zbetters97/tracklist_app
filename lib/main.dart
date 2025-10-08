import 'package:flutter/material.dart';
import 'package:tracklist_app/data/constants.dart';
import 'package:tracklist_app/services/spotify_search.dart';
import 'package:tracklist_app/views/widget_tree.dart';

void main() async {
  runApp(const MyApp());
}

void searchDemo() async {
  final List<Map<String, dynamic>> albums = await searchAlbums(album: 'Landmark');
  print('Search for: "Landmark":');
  for (final Map<String, dynamic> album in albums) {
    print('${album['name']} by ${album['artist']} [${album['release_date']}] Cover: ${album['image']}');
  }

  final List<Map<String, dynamic>> artists = await searchArtists(artist: 'Hippo Campus');
  print('Search for: "Hippo Campus":');
  for (final Map<String, dynamic> artist in artists) {
    print('${artist['name']}, Cover: ${artist['image']}');
  }

  final List<Map<String, dynamic>> artist = await searchArtists(artist: 'Hippo Campus');
  String artistId = artist[0]['id'] as String;

  final List<Map<String, dynamic>> artistAlbums = await getArtistAlbums(artistId: artistId);
  artistAlbums.sort((a, b) => a['release_date'].compareTo(b['release_date']));

  print("Albums by ${artist[0]['name']}:");
  for (final Map<String, dynamic> album in artistAlbums) {
    print('[${album['release_date']}] ${album['name']}: Cover: ${album['image']}');
  }

  final List<Map<String, dynamic>> album = await searchAlbums(album: 'Landmark');
  String albumId = album[0]['id'] as String;

  final List<Map<String, dynamic>> albumTracks = await getAlbumTracks(albumId);
  albumTracks.sort((a, b) => a['track_number'].compareTo(b['track_number']));

  print("Tracks from ${album[0]['name']}:");
  for (final Map<String, dynamic> track in albumTracks) {
    double minutes = track['duration'] ~/ 1000 / 60;
    print('[${track['track_number']}] ${track['name']}: ${minutes.toStringAsFixed(2)} mins');
  }
}

// Stateless: screen cannot be changed (can't refresh/update)
// Stateful: screen can be changed (can refresh/update)
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spotify Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: PRIMARY_COLOR, brightness: Brightness.dark),
      ),
      home: WidgetTree(),
    );
  }
}
