import 'package:flutter/material.dart';
import 'package:tracklist_app/data/classes/auth_user_class.dart';
import 'package:tracklist_app/data/constants.dart';
import 'package:tracklist_app/data/utils/date.dart';
import 'package:tracklist_app/data/utils/notifiers.dart';
import 'package:tracklist_app/data/utils/string_extensions.dart';
import 'package:tracklist_app/services/auth_service.dart';
import 'package:tracklist_app/views/pages/welcome/welcome_page.dart';
import 'package:tracklist_app/views/widgets/my_app_bar.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key, this.uid = ""});

  final String uid;

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  bool isLoading = true;
  late AuthUser user;

  @override
  void initState() {
    super.initState();
    fetchUser();
  }

  void fetchUser() async {
    isLoading = true;

    String uid = widget.uid == "" ? authUser.value!.uid : widget.uid;
    AuthUser tempUser = await authService.value.getUserById(userId: uid);

    // User is on their own profile, go to Profile tab
    if (uid == authUser.value!.uid) {
      selectedPageNotifier.value = 4;
    }

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

    return Scaffold(
      appBar: MyAppBar(title: user.username),
      backgroundColor: BACKGROUND_COLOR,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          buildProfile(user.profileUrl),
          const SizedBox(height: 4),
          buildBio(user.bio),
          const SizedBox(height: 4),
          buildUserDate(user.createdAt.toDate()),
          ListTile(onTap: onLogoutPressed, title: const Text("Logout")),
        ],
      ),
    );
  }

  Widget buildProfile(String profileUrl) {
    Image profileImage = profileUrl.startsWith("https") ? Image.network(profileUrl) : Image.asset(DEFAULT_PROFILE_IMG);

    return Column(
      children: [
        CircleAvatar(radius: 50.0, backgroundImage: profileImage.image),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(user.displayname.capitalizeEachWord(), style: const TextStyle(color: Colors.white, fontSize: 20)),
            SizedBox(width: 5),
            Text("@${user.username}"),
          ],
        ),
      ],
    );
  }

  Widget buildBio(String bio) {
    if (bio == "") {
      return Container();
    }

    return Text(
      bio,
      style: const TextStyle(color: Colors.white, fontSize: 16, fontStyle: FontStyle.italic),
    );
  }

  Widget buildUserDate(DateTime joinedOn) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.calendar_today, color: Colors.grey, size: 20),
        SizedBox(width: 2),
        Text("Joined on ${formatDateMDYLong(joinedOn)}", style: TextStyle(fontSize: 14)),
      ],
    );
  }
}
