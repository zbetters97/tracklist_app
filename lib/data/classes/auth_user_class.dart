class AuthUser {
  final String email;
  final String username;
  final String displayName;
  final String profileUrl;

  AuthUser({required this.email, required this.username, required this.displayName, required this.profileUrl});

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      email: json['email'],
      username: json['username'],
      displayName: json['displayName'],
      profileUrl: json['profileUrl'],
    );
  }
}
