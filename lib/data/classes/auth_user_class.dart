import 'package:cloud_firestore/cloud_firestore.dart';

class AuthUser {
  final String uid;
  final String email;
  final String username;
  final String displayname;
  final DateTime createdAt;
  final String bio;
  final String profileUrl;

  AuthUser({
    required this.uid,
    required this.email,
    required this.username,
    required this.displayname,
    required this.createdAt,
    required this.bio,
    required this.profileUrl,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      uid: json['uid'],
      email: json['email'],
      username: json['username'],
      displayname: json['displayname'],
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      bio: json['bio'],
      profileUrl: json['profileUrl'],
    );
  }
}
