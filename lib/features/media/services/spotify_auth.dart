import 'dart:convert';
import 'package:http/http.dart' as http;

class SpotifyAuth {
  // Store Client ID and Client Secret from the Spotify developer dashboard
  final String clientId;
  final String clientSecret;

  String? _accessToken;
  DateTime? _tokenExpiry;

  // Constructor
  SpotifyAuth({required this.clientId, required this.clientSecret});

  // Fetch access token, Future means the value will be returned in later
  Future<String?> getAccessToken() async {
    // Check if token is still valid
    if (_accessToken != null && _tokenExpiry != null) {
      // If token is still valid, return it
      if (DateTime.now().isBefore(_tokenExpiry!)) {
        return _accessToken;
      }
    }

    try {
      // Fetch a new access token from the Spotify API using the client ID and client secret
      final response = await http.post(
        Uri.parse('https://accounts.spotify.com/api/token'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Basic ${base64Encode(utf8.encode('$clientId:$clientSecret'))}',
        },
        body: {'grant_type': 'client_credentials'},
      );

      // Unsuccessful response if the status code is not 200
      if (response.statusCode != 200) {
        throw Exception('Failed to fetch access token: ${response.body}');
      }

      final data = jsonDecode(response.body);

      // Store access token and expiry in class-accessible variables
      _accessToken = data['access_token'];

      // Token expires measured in seconds
      final expiresIn = data['expires_in'];
      _tokenExpiry = DateTime.now().add(Duration(seconds: expiresIn));

      return _accessToken;
    } catch (error) {
      throw Exception('Error fetching access token: $error');
    }
  }
}
