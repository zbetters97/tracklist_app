class AuthUser {
  final String uid;
  final String email;
  final String username;
  final String displayname;
  final String profileUrl;

  AuthUser({
    required this.uid,
    required this.email,
    required this.username,
    required this.displayname,
    required this.profileUrl,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      uid: json['uid'],
      email: json['email'],
      username: json['username'],
      displayname: json['displayname'],
      profileUrl: json['profileUrl'],
    );
  }
}
