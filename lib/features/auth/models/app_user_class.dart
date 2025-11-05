import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String email;
  final String username;
  final String displayname;
  final DateTime createdAt;
  final String bio;
  final String profileUrl;
  List<String> followers;
  List<String> following;

  AppUser({
    required this.uid,
    required this.email,
    required this.username,
    required this.displayname,
    required this.createdAt,
    required this.bio,
    required this.profileUrl,
    required this.followers,
    required this.following,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      uid: json['uid'],
      email: json['email'],
      username: json['username'],
      displayname: json['displayname'],
      createdAt: (json['created_at'] as Timestamp).toDate(),
      bio: json['bio'],
      profileUrl: json['profile_url'],
      followers: List<String>.from(json['followers']),
      following: List<String>.from(json['following']),
    );
  }
}
