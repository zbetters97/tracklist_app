import 'package:flutter/material.dart';
import 'package:tracklist_app/data/notifiers.dart';
import 'package:tracklist_app/data/string_extensions.dart';
import 'package:tracklist_app/services/auth_service.dart';
import 'package:tracklist_app/views/pages/welcome_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.onOpenReview});

  final void Function(Map<String, dynamic> review) onOpenReview;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  void onLogoutPressed() {
    selectedPageNotifier.value = 0;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) {
          return WelcomePage();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(radius: 50.0, backgroundImage: AssetImage(authUser.value!.profileUrl)),
        Text("Welcome, ${authUser.value!.displayName.capitalizeEachWord()}!"),
        ListTile(onTap: onLogoutPressed, title: const Text("Logout")),
      ],
    );
  }
}
