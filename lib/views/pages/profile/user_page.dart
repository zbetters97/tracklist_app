import 'package:flutter/material.dart';
import 'package:tracklist_app/data/constants.dart';
import 'package:tracklist_app/data/notifiers.dart';
import 'package:tracklist_app/data/string_extensions.dart';
import 'package:tracklist_app/date.dart';
import 'package:tracklist_app/services/auth_service.dart';
import 'package:tracklist_app/views/pages/welcome_page.dart';
import 'package:tracklist_app/views/widgets/my_app_bar.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key, this.uid = ""});

  final String uid;

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  bool isLoading = true;
  Map<String, dynamic> user = {};

  @override
  void initState() {
    super.initState();
    fetchUser();
  }

  void fetchUser() async {
    isLoading = true;

    String uid = widget.uid == "" ? authUser.value!.uid : widget.uid;
    Map<String, dynamic> tempUser = await authService.value.getUserById(userId: uid);

    setState(() {
      user = tempUser;
      isLoading = false;
    });
  }

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
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: PRIMARY_COLOR_DARK));
    }

    Image profileImage = user["profileUrl"].startsWith("https")
        ? Image.network(user["profileUrl"])
        : Image.asset(DEFAULT_PROFILE_IMG);

    return Scaffold(
      appBar: MyAppBar(title: user["username"] ?? "User"),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(radius: 50.0, backgroundImage: profileImage.image),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                user["displayname"].toString().capitalizeEachWord(),
                style: const TextStyle(color: Colors.white, fontSize: 20),
              ),
              SizedBox(width: 5),
              Text("@${user["username"]}"),
            ],
          ),
          if (user["bio"] != "")
            Text(
              "${user["bio"]}",
              style: const TextStyle(color: Colors.white, fontSize: 16, fontStyle: FontStyle.italic),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.calendar_month_outlined),
              SizedBox(width: 5),
              Text("Joined on ${formatDateMDYLong(user["createdAt"].toDate())}"),
            ],
          ),
          ListTile(onTap: onLogoutPressed, title: const Text("Logout")),
        ],
      ),

      backgroundColor: BACKGROUND_COLOR,
    );
  }
}
