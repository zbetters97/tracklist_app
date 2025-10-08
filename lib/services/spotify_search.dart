import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tracklist_app/data/constants.dart';
import 'spotify_auth.dart';

// Create an instance of the SpotifyAuth class using the client ID and client secret constants
final SpotifyAuth _auth = SpotifyAuth(clientId: CLIENT_ID, clientSecret: CLIENT_SECRET);

/// Search albums by name on Spotify
/// [album] The name of the album
/// [limit] The maximum number of albums to return
/// Returns a list of albums
Future<List<Map<String, dynamic>>> searchAlbums({required String album, int limit = 5}) async {
  // Get access token
  final token = await _auth.getAccessToken();

  // Cannot retrieve access token
  if (token == null) {
    throw Exception('Unable to get access token');
  }

  // Store HTTP response
  final response = await http.get(
    Uri.parse('https://api.spotify.com/v1/search?q=$album&type=album&limit=$limit'),
    headers: {'Authorization': 'Bearer $token'},
  );

  // Cannot retrieve HTTP response
  if (response.statusCode != 200) {
    print('Error searching albums: ${response.body}');
    throw Exception('Spotify API error: ${response.statusCode}');
  }

  // Decode JSON response
  final data = jsonDecode(response.body);
  final albums = data['albums']['items'] as List;

  // Return list of albums
  return albums
      .map<Map<String, dynamic>>(
        (album) => {
          'name': album['name'],
          'id': album['id'],
          'artist': album['artists'][0]['name'],
          'image': album['images'].isNotEmpty ? album['images'][0]['url'] : "",
          'release_date': album['release_date'],
        },
      )
      .toList();
}

/// Search artists by name on Spotify
/// [artist] The name of the artist
/// [limit] The maximum number of artists to return
/// Returns a list of artists
Future<List<Map<String, dynamic>>> searchArtists({required String artist, int limit = 5}) async {
  final token = await _auth.getAccessToken();

  if (token == null) {
    throw Exception('Unable to get access token');
  }

  final response = await http.get(
    Uri.parse('https://api.spotify.com/v1/search?q=$artist&type=artist&limit=$limit'),
    headers: {'Authorization': 'Bearer $token'},
  );

  if (response.statusCode != 200) {
    print('Error searching artists: ${response.body}');
    throw Exception('Spotify API error: ${response.statusCode}');
  }

  final data = jsonDecode(response.body);
  final artists = data['artists']['items'] as List;

  return artists
      .map<Map<String, dynamic>>(
        (artist) => {
          'name': artist['name'],
          'id': artist['id'],
          'image': artist['images'].isNotEmpty ? artist['images'][0]['url'] : "",
        },
      )
      .toList();
}

/// Search media by category on Spotify
/// [category] The category of the media
/// [name] The name of the media
/// [limit] The maximum number of entries to return
/// Returns a list of media entries
Future<List<Map<String, dynamic>>> searchByCategory({
  required String category,
  required String name,
  int limit = 5,
}) async {
  final token = await _auth.getAccessToken();

  if (token == null) {
    throw Exception('Unable to get access token');
  }

  final response = await http.get(
    Uri.parse('https://api.spotify.com/v1/search?q=$name&type=$category&limit=$limit'),
    headers: {'Authorization': 'Bearer $token'},
  );

  if (response.statusCode != 200) {
    print('Error searching for media: ${response.body}');
    throw Exception('Spotify API error: ${response.statusCode}');
  }

  final data = jsonDecode(response.body);
  List<Map<String, dynamic>> media = [];

  if (category == "artist") {
    media = data['artists']['items']
        .map<Map<String, dynamic>>(
          (artist) => {
            'name': artist['name'],
            'id': artist['id'],
            'image': artist['images'].isNotEmpty ? artist['images'][0]['url'] : "",
          },
        )
        .toList();
  } else if (category == "album") {
    media = data['albums']['items']
        .map<Map<String, dynamic>>(
          (album) => {
            'name': album['name'],
            'id': album['id'],
            'artist': album['artists'][0]['name'],
            'image': album['images'].isNotEmpty ? album['images'][0]['url'] : "",
            'release_date': album['release_date'],
          },
        )
        .toList();
  } else if (category == "track") {
    media = data['tracks']['items']
        .map<Map<String, dynamic>>(
          (track) => {
            'name': track['name'],
            'id': track['id'],
            'image': track['album']['images'].isNotEmpty ? track['album']['images'][0]['url'] : "",
            'track_number': track['track_number'],
            'duration': track['duration_ms'],
          },
        )
        .toList();
  }

  return media;
}

Future<Map<String, dynamic>> getArtistById(String artistId) async {
  final token = await _auth.getAccessToken();

  if (token == null) {
    throw Exception('Unable to get access token');
  }

  final response = await http.get(
    Uri.parse('https://api.spotify.com/v1/artists/$artistId'),
    headers: {'Authorization': 'Bearer $token'},
  );

  if (response.statusCode != 200) {
    print('Error searching artist: ${response.body}');
    throw Exception('Spotify API error: ${response.statusCode}');
  }

  final data = jsonDecode(response.body);

  return {'name': data['name'], 'id': data['id'], 'image': data['images'].isNotEmpty ? data['images'][0]['url'] : ""};
}

/// Get albums by artist ID
/// [artistId] The ID of the artist
/// [limit] The maximum number of albums to return
/// Returns a list of albums
Future<List<Map<String, dynamic>>> getArtistAlbums({required String artistId, int limit = 5}) async {
  final token = await _auth.getAccessToken();

  if (token == null) {
    throw Exception('Unable to get access token');
  }

  final response = await http.get(
    Uri.parse('https://api.spotify.com/v1/artists/$artistId/albums?include_groups=album&limit=$limit'),
    headers: {'Authorization': 'Bearer $token'},
  );

  if (response.statusCode != 200) {
    print('Error searching artist albums: ${response.body}');
    throw Exception('Spotify API error: ${response.statusCode}');
  }

  final data = jsonDecode(response.body);
  final albums = data['items'] as List;

  return albums
      .map<Map<String, dynamic>>(
        (album) => {
          'name': album['name'],
          'id': album['id'],
          'image': album['images'].isNotEmpty ? album['images'][0]['url'] : "",
          'release_date': album['release_date'],
        },
      )
      .toList();
}

/// Get tracks by album ID
/// [albumId] The ID of the album
/// Returns a list of tracks
Future<List<Map<String, dynamic>>> getAlbumTracks(String albumId) async {
  final token = await _auth.getAccessToken();

  if (token == null) {
    throw Exception('Unable to get access token');
  }

  final response = await http.get(
    Uri.parse('https://api.spotify.com/v1/albums/$albumId/tracks'),
    headers: {'Authorization': 'Bearer $token'},
  );

  if (response.statusCode != 200) {
    print('Error searching artist tracks: ${response.body}');
    throw Exception('Spotify API error: ${response.statusCode}');
  }

  final data = jsonDecode(response.body);
  final tracks = data['items'] as List;

  return tracks
      .map<Map<String, dynamic>>(
        (track) => {
          'name': track['name'],
          'id': track['id'],
          'image': track['album']['images'].isNotEmpty ? track['album']['images'][0]['url'] : "",
          'track_number': track['track_number'],
          'duration': track['duration_ms'],
        },
      )
      .toList();
}
