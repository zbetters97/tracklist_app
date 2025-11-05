import 'package:flutter/material.dart';
import 'package:tracklist_app/features/auth/models/auth_user_class.dart';
import 'package:tracklist_app/core/constants/constants.dart';
import 'package:tracklist_app/core/utils/date.dart';
import 'package:tracklist_app/core/utils/notifiers.dart';
import 'package:tracklist_app/core/extensions/string_extensions.dart';
import 'package:tracklist_app/features/auth/services/auth_service.dart';
import 'package:tracklist_app/features/user/widgets/user_reviews_section.dart';
import 'package:tracklist_app/features/welcome/pages/welcome_page.dart';
import 'package:tracklist_app/core/widgets/my_app_bar.dart';
import 'package:tracklist_app/features/user/widgets/user_app_bar.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key, this.uid = ""});

  final String uid;

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  bool isLoading = true;
  late AuthUser user;
  bool isLoggedInUser = false;
  bool isFollowing = false;
  int followers = 0;
  int following = 0;

  @override
  void initState() {
    super.initState();
    fetchUser();
  }

  void fetchUser() async {
    isLoading = true;

    // If no passed uid, get current user's uid
    String uid = widget.uid == "" ? authUser.value!.uid : widget.uid;

    // User is on their own profile, highlight Profile tab
    if (uid == authUser.value!.uid) {
      selectedPageNotifier.value = 4;

      setState(() {
        user = authUser.value!;
        isLoggedInUser = true;
      });
    } else {
      AuthUser fetchedUser = await authService.value.getUserById(userId: uid);

      setState(() {
        user = fetchedUser;
        isLoggedInUser = false;
        isFollowing = fetchedUser.followers.contains(authUser.value!.uid);
      });
    }

    setState(() {
      followers = user.followers.length;
      following = user.following.length;
      isLoading = false;
    });
  }

  void onFollowPressed() async {
    if (isFollowing) {
      await authService.value.unfollowUser(userId: user.uid);
    } else {
      await authService.value.followUser(userId: user.uid);
    }

    setState(() {
      isFollowing = !isFollowing;
      followers = isFollowing ? followers + 1 : followers - 1;
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
      appBar: isLoggedInUser ? UserAppBar(user: user, onLogoutPressed: onLogoutPressed) : MyAppBar(title: ""),
      backgroundColor: BACKGROUND_COLOR,
      extendBodyBehindAppBar: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                buildProfile(user.profileUrl),
                const SizedBox(height: 4),
                buildBio(user.bio),
                const SizedBox(height: 4),
                buildDate(user.createdAt),
                const SizedBox(height: 4),
                buildFriends(followers, following),
                const SizedBox(height: 4),
                buildFollowButton(),
              ],
            ),
          ),
          UserReviewsSection(user: user),
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
            const SizedBox(width: 5),
            Text("@${user.username}", style: const TextStyle(color: Colors.grey, fontSize: 16)),
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
      style: const TextStyle(color: Colors.white, fontSize: 18, fontStyle: FontStyle.italic),
    );
  }

  Widget buildDate(DateTime joinedOn) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.calendar_today, color: Colors.grey, size: 18),
        const SizedBox(width: 2),
        Text("Joined on ${formatDateMDYLong(joinedOn)}", style: TextStyle(fontSize: 16)),
      ],
    );
  }

  Widget buildFriends(int followers, int following) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text.rich(
          TextSpan(
            style: TextStyle(color: Colors.grey, fontSize: 16),
            children: [
              TextSpan(
                text: followers.toString(),
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              TextSpan(text: " followers"),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Text.rich(
          TextSpan(
            style: TextStyle(color: Colors.grey, fontSize: 16),
            children: [
              TextSpan(
                text: following.toString(),
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              TextSpan(text: " following"),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildFollowButton() {
    if (isLoggedInUser) return Container();

    String buttonText = isFollowing ? "Following" : "Follow";

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () => onFollowPressed(),
          style: ElevatedButton.styleFrom(backgroundColor: PRIMARY_COLOR_DARK, shape: RoundedRectangleBorder()),
          child: Text(
            buttonText,
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
