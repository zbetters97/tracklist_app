class AppUser {
  final String uid;
  final String email;
  final String username;
  final String displayName;

  AppUser({required this.uid, required this.email, required this.username, required this.displayName});

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      uid: json['uid'],
      email: json['email'],
      username: json['username'],
      displayName: json['displayName'],
    );
  }
}
