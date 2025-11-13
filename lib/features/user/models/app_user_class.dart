import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tracklist_app/core/constants/constants.dart';

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

  // Overrides default .toSet() to use the uid as the unique key
  @override
  bool operator ==(Object other) => identical(this, other) || other is AppUser && uid == other.uid;

  // Use uid as the unique key
  @override
  int get hashCode => uid.hashCode;

  Widget buildProfileAndUsername(BuildContext context, double fontSize, double profileSize) {
    return Row(
      spacing: 5.0,
      children: [
        buildProfileImage(context, profileSize),
        Text(
          "@$username",
          style: TextStyle(color: Colors.grey, fontSize: fontSize),
        ),
      ],
    );
  }

  Widget buildProfileImage(BuildContext context, double size) {
    return GestureDetector(
      onTap: () {
        showGeneralDialog(
          context: context,
          barrierLabel: "Profile Image",
          barrierDismissible: true,
          barrierColor: Colors.black54,
          transitionDuration: Duration(milliseconds: 200),
          pageBuilder: (context, anim1, anim2) {
            return Center(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: ClipOval(
                  child: InteractiveViewer(
                    child: Image(
                      image: profileUrl.startsWith("https")
                          ? NetworkImage(profileUrl)
                          : AssetImage(DEFAULT_PROFILE_IMG) as ImageProvider,
                      fit: BoxFit.cover,
                      width: 300,
                      height: 300,
                    ),
                  ),
                ),
              ),
            );
          },
          transitionBuilder: (context, anim1, anim2, child) {
            return FadeTransition(opacity: anim1, child: child);
          },
        );
      },
      child: CircleAvatar(
        radius: size,
        backgroundImage: profileUrl.startsWith("https")
            ? NetworkImage(profileUrl)
            : AssetImage(DEFAULT_PROFILE_IMG) as ImageProvider,
      ),
    );
  }
}
