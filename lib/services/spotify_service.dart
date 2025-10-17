import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tracklist_app/data/classes/album_class.dart';
import 'package:tracklist_app/data/classes/artist_class.dart';
import 'package:tracklist_app/data/classes/media_class.dart';
import 'package:tracklist_app/data/classes/track_class.dart';
import 'package:tracklist_app/data/constants.dart';
import 'spotify_auth.dart';

// Create an instance of the SpotifyAuth class using the client ID and client secret constants
final SpotifyAuth _auth = SpotifyAuth(clientId: CLIENT_ID, clientSecret: CLIENT_SECRET);

/// Search media by category on Spotify
/// [category] The category of the media
/// [name] The name of the media
/// [limit] The maximum number of entries to return
/// Returns a list of Media objects
Future<List<Media>> searchByCategory({required String category, required String name, int limit = MAX_LIMIT}) async {
  final token = await _auth.getAccessToken();

  if (token == null) {
    throw Exception('Unable to get access token');
  }

  final response = await http.get(
    Uri.parse('https://api.spotify.com/v1/search?q=$name&type=$category&limit=$limit&market=US'),
    headers: {'Authorization': 'Bearer $token'},
  );

  if (response.statusCode != 200) {
    throw Exception('Spotify API error: ${response.statusCode}');
  }

  final data = jsonDecode(response.body);
  List<Media> media = [];

  if (category == "artist") {
    media = data['artists']['items'].map<Artist>((artist) => parseSpotifyArtist(artist)).toList();
  } else if (category == "album") {
    media = data['albums']['items'].map<Album>((album) => parseSpotifyAlbum(album)).toList();
  } else if (category == "track") {
    media = data['tracks']['items'].map<Track>((track) => parseSpotifyTrack(track)).toList();
  }

  return media;
}

/// Search artists by name on Spotify
/// [artist] The name of the artist
/// [limit] The maximum number of artists to return
/// Returns a list of Artist objects
Future<List<Artist>> searchArtists({required String artist, int limit = MAX_LIMIT}) async {
  final token = await _auth.getAccessToken();

  if (token == null) {
    throw Exception('Unable to get access token');
  }

  final response = await http.get(
    Uri.parse('https://api.spotify.com/v1/search?q=$artist&type=artist&limit=$limit&market=US'),
    headers: {'Authorization': 'Bearer $token'},
  );

  if (response.statusCode != 200) {
    throw Exception('Spotify API error: ${response.statusCode}');
  }

  final data = jsonDecode(response.body);

  return data['artists']['items'].map<Artist>((artist) => parseSpotifyArtist(artist)).toList();
}

/// Search albums by name on Spotify
/// [album] The name of the album
/// [limit] The maximum number of albums to return
/// Returns a list of Album objects
Future<List<Album>> searchAlbums({required String album, int limit = MAX_LIMIT}) async {
  // Get access token
  final token = await _auth.getAccessToken();

  // Cannot retrieve access token
  if (token == null) {
    throw Exception('Unable to get access token');
  }

  // Store HTTP response
  final response = await http.get(
    Uri.parse('https://api.spotify.com/v1/search?q=$album&type=album&limit=$limit&market=US'),
    headers: {'Authorization': 'Bearer $token'},
  );

  // Cannot retrieve HTTP response
  if (response.statusCode != 200) {
    throw Exception('Spotify API error: ${response.statusCode}');
  }

  // Decode JSON response
  final data = jsonDecode(response.body);

  // Return list of albums
  return data['albums']['items'].map<Album>((album) => parseSpotifyAlbum(album)).toList();
}

/// Search tracks by name on Spotify
/// [track] The name of the track
/// [limit] The maximum number of tracks to return
/// Returns a list of Track objects
Future<List<Album>> searchTracks({required String track, int limit = MAX_LIMIT}) async {
  // Get access token
  final token = await _auth.getAccessToken();

  // Cannot retrieve access token
  if (token == null) {
    throw Exception('Unable to get access token');
  }

  // Store HTTP response
  final response = await http.get(
    Uri.parse('https://api.spotify.com/v1/search?q=$track&type=track&limit=$limit&market=US'),
    headers: {'Authorization': 'Bearer $token'},
  );

  // Cannot retrieve HTTP response
  if (response.statusCode != 200) {
    throw Exception('Spotify API error: ${response.statusCode}');
  }

  // Decode JSON response
  final data = jsonDecode(response.body);

  // Return list of tracks
  return data['tracks']['items'].map<Track>((track) => parseSpotifyTrack(track)).toList();
}

/// Get media by the ID and category on Spotify
/// [mediaId] The ID of the media
/// [category] The category of the media
/// Returns a Media object based on the ID and category
Future<Media> getMediaById(String mediaId, String category) async {
  Media media = category == "artist"
      ? await getArtistById(mediaId)
      : category == "album"
      ? await getAlbumById(mediaId)
      : await getTrackById(mediaId);

  return media;
}

/// Get artist by ID on Spotify
/// [artistId] The ID of the artist
/// Returns an Artist object based on the ID
Future<Artist> getArtistById(String artistId) async {
  final token = await _auth.getAccessToken();

  if (token == null) {
    throw Exception('Unable to get access token');
  }

  final response = await http.get(
    Uri.parse('https://api.spotify.com/v1/artists/$artistId?market=US'),
    headers: {'Authorization': 'Bearer $token'},
  );

  if (response.statusCode != 200) {
    throw Exception('Spotify API error: ${response.statusCode}');
  }

  final artist = jsonDecode(response.body);

  return parseSpotifyArtist(artist);
}

/// Get album by ID on Spotify
/// [albumId] The ID of the album
/// Returns an Album object based on the ID
Future<Album> getAlbumById(String albumId) async {
  final token = await _auth.getAccessToken();

  if (token == null) {
    throw Exception('Unable to get access token');
  }

  final response = await http.get(
    Uri.parse('https://api.spotify.com/v1/albums/$albumId?market=US'),
    headers: {'Authorization': 'Bearer $token'},
  );

  if (response.statusCode != 200) {
    throw Exception('Spotify API error: ${response.statusCode}');
  }

  final album = jsonDecode(response.body);

  return parseSpotifyAlbum(album);
}

/// Get track by ID on Spotify
/// [trackId] The ID of the track
/// Returns a Track object based on the ID
Future<Track> getTrackById(String trackId) async {
  final token = await _auth.getAccessToken();

  if (token == null) {
    throw Exception('Unable to get access token');
  }

  print(trackId);

  final response = await http.get(
    Uri.parse('https://api.spotify.com/v1/tracks/$trackId?market=US'),
    headers: {'Authorization': 'Bearer $token'},
  );

  if (response.statusCode != 200) {
    throw Exception('Spotify API error: ${response.statusCode}');
  }

  final track = jsonDecode(response.body);

  return parseSpotifyTrack(track);
}

/// Get albums by artist ID on Spotify
/// [artistId] The ID of the artist
/// Returns a list of Album objects
Future<List<Album>> getArtistAlbums({required String artistId}) async {
  final token = await _auth.getAccessToken();

  if (token == null) {
    throw Exception('Unable to get access token');
  }

  final response = await http.get(
    Uri.parse('https://api.spotify.com/v1/artists/$artistId/albums?include_groups=album&market=US'),
    headers: {'Authorization': 'Bearer $token'},
  );

  if (response.statusCode != 200) {
    throw Exception('Spotify API error: ${response.statusCode}');
  }

  final data = jsonDecode(response.body);

  return data['items'].map<Album>((album) => parseSpotifyAlbum(album)).toList();
}

/// Get singles by artist ID on Spotify
/// [artistId] The ID of the artist
/// Returns a list of Track objects
Future<List<Track>> getArtistSingles({required String artistId}) async {
  final token = await _auth.getAccessToken();

  if (token == null) {
    throw Exception('Unable to get access token');
  }

  final response = await http.get(
    Uri.parse('https://api.spotify.com/v1/artists/$artistId/albums?include_groups=single&market=US'),
    headers: {'Authorization': 'Bearer $token'},
  );

  if (response.statusCode != 200) {
    throw Exception('Spotify API error: ${response.statusCode}');
  }

  final data = jsonDecode(response.body);

  return data['items'].map<Track>((track) => parseSpotifyTrack(track)).toList();
}

/// Get tracks by album ID on Spotify
/// [albumId] The ID of the album
/// Returns a list of Track objects
Future<List<Track>> getAlbumTracks(String albumId) async {
  final token = await _auth.getAccessToken();

  if (token == null) {
    throw Exception('Unable to get access token');
  }

  final response = await http.get(
    Uri.parse('https://api.spotify.com/v1/albums/$albumId/tracks&market=US'),
    headers: {'Authorization': 'Bearer $token'},
  );

  if (response.statusCode != 200) {
    throw Exception('Spotify API error: ${response.statusCode}');
  }

  final data = jsonDecode(response.body);

  return data['items'].map<Track>((track) => parseSpotifyTrack(track)).toList();
}

/// Create an Artist object from a map
/// [artist] The artist map from the Spotify API
/// Returns an Artist object
Artist parseSpotifyArtist(Map<String, dynamic> artist) {
  return Artist.fromJson({
    'name': artist['name'],
    'id': artist['id'],
    'image': artist['images'].isNotEmpty ? artist['images'][0]['url'] : DEFAULT_MEDIA_IMG,
    'spotify': artist['external_urls']['spotify'],
  });
}

/// Create an Album object from a map
/// [album] The album map from the Spotify API
/// Returns an Album object
Album parseSpotifyAlbum(Map<String, dynamic> album) {
  return Album.fromJson({
    'name': album['name'],
    'id': album['id'],
    'artist': album['artists'][0]['name'],
    'image': album['images'].isNotEmpty ? album['images'][0]['url'] : DEFAULT_MEDIA_IMG,
    'release_date': album['release_date'],
    'spotify': album['external_urls']['spotify'],
  });
}

/// Create a Track object from a map
/// [track] The track map from the Spotify API
/// Returns a Track object
Track parseSpotifyTrack(Map<String, dynamic> track) {
  return Track.fromJson({
    'name': track['name'],
    'id': track['id'],
    'artist': track['artists'][0]['name'],
    'album': track['album'] != null ? track['album']['name'] : '',
    'image': track['album'] != null
        ? track['album']['images'][0]['url']
        : track['images'][0]['url'] ?? DEFAULT_MEDIA_IMG,
    'track_number': track['track_number'] ?? 0,
    'release_date': track['album'] != null ? track['album']['release_date'] : track['release_date'],
    'spotify': track['external_urls']['spotify'],
  });
}
