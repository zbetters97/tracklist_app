class AuthUser {
  final String email;
  final String username;
  final String displayName;

  AuthUser({required this.email, required this.username, required this.displayName});

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(email: json['email'], username: json['username'], displayName: json['displayName']);
  }
}
