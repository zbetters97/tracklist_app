import 'package:flutter/material.dart';
import 'package:tracklist_app/core/widgets/loading_icon.dart';
import 'package:tracklist_app/features/user/content/user_likes_content.dart';
import 'package:tracklist_app/features/user/models/app_user_class.dart';
import 'package:tracklist_app/core/constants/constants.dart';
import 'package:tracklist_app/core/utils/date.dart';
import 'package:tracklist_app/core/utils/notifiers.dart';
import 'package:tracklist_app/core/extensions/string_extensions.dart';
import 'package:tracklist_app/features/user/pages/user_friends_page.dart';
import 'package:tracklist_app/features/user/services/user_service.dart';
import 'package:tracklist_app/features/user/widgets/user_follow_button.dart';
import 'package:tracklist_app/features/user/content/user_reviews_content.dart';
import 'package:tracklist_app/features/welcome/pages/welcome_page.dart';
import 'package:tracklist_app/core/widgets/default_app_bar.dart';
import 'package:tracklist_app/features/user/widgets/user_app_bar.dart';

class UserPage extends StatefulWidget {
  final String uid;

  const UserPage({super.key, this.uid = ""});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  bool isLoading = true;
  late AppUser user;
  bool isLoggedInUser = false;

  final List<String> tabs = ["Reviews", "Lists", "Likes"];
  int selectedTab = 0;

  @override
  void initState() {
    super.initState();
    fetchUser();
  }

  void fetchUser() async {
    setState(() => isLoading = true);

    // If no passed uid, get current user's uid
    String uid = widget.uid == "" ? authUser.value!.uid : widget.uid;

    if (!mounted) return;

    isLoggedInUser = uid == authUser.value!.uid;

    // User is on their own profile, highlight Profile tab
    if (isLoggedInUser) {
      // Wait for build to finish
      WidgetsBinding.instance.addPostFrameCallback((_) {
        selectedPageNotifier.value = 4;
      });
      setState(() => user = authUser.value!);
    } else {
      AppUser fetchedUser = await getUserById(userId: uid);
      setState(() => user = fetchedUser);
    }

    if (!mounted) return;

    setState(() => isLoading = false);
  }

  void onFollowChanged(bool isFollowing) {
    setState(() {
      if (isFollowing) {
        user.followers.remove(authUser.value!.uid);
      } else {
        user.followers.add(authUser.value!.uid);
      }
    });
  }

  void onLogoutPressed() {
    authService.value.signOut();

    // Reset selected page
    selectedPageNotifier.value = 0;

    Navigator.of(
      context,
      rootNavigator: true,
    ).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const WelcomePage()), (route) => false);
  }

  void sendToFriendsPage(bool isFollowers) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserFriendsPage(user: user, isFollowers: isFollowers),
      ),
    );
  }

  @override
  void dispose() {
    isLoading = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return LoadingIcon();
    }

    return Scaffold(
      appBar: isLoggedInUser ? UserAppBar(user: user, onLogoutPressed: onLogoutPressed) : DefaultAppBar(title: ""),
      backgroundColor: BACKGROUND_COLOR,
      extendBodyBehindAppBar: true,
      body: buildUserProfile(),
    );
  }

  Widget buildUserProfile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 3.0,
            children: [
              buildProfile(),
              buildBio(),
              buildDate(),
              buildFriends(),
              if (!isLoggedInUser) UserFollowButton(user: user, onFollowChanged: onFollowChanged),
            ],
          ),
        ),
        buildUserTabs(),
        buildSelectedTab(),
      ],
    );
  }

  Widget buildProfile() {
    return Column(children: [user.buildProfileImage(context, 50.0), buildUsername()]);
  }

  Widget buildUsername() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 5.0,
      children: [
        Text(
          user.displayname.capitalizeEachWord(),
          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text("@${user.username}", style: const TextStyle(color: Colors.grey, fontSize: 16)),
      ],
    );
  }

  Widget buildBio() {
    if (user.bio == "") {
      return Container();
    }

    return Text(
      user.bio,
      style: const TextStyle(color: Colors.white, fontSize: 18, fontStyle: FontStyle.italic),
    );
  }

  Widget buildDate() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 2.0,
      children: [
        Icon(Icons.calendar_today, color: Colors.grey, size: 18),
        Text("Joined on ${formatDateMDYLong(user.createdAt)}", style: TextStyle(fontSize: 16)),
      ],
    );
  }

  Widget buildFriends() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 10.0,
      children: [buildFriendsTab(true), buildFriendsTab(false)],
    );
  }

  Widget buildFriendsTab(bool isFollowers) {
    String text = isFollowers ? user.followers.length.toString() : user.following.length.toString();

    return GestureDetector(
      onTap: () => sendToFriendsPage(isFollowers),
      child: Text.rich(
        TextSpan(
          style: TextStyle(color: Colors.grey, fontSize: 16),
          children: [
            TextSpan(
              text: text,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            TextSpan(text: isFollowers ? " followers" : " following"),
          ],
        ),
      ),
    );
  }

  Widget buildUserTabs() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: ToggleButtons(
        isSelected: List.generate(tabs.length, (index) => index == selectedTab),
        onPressed: (index) => setState(() {
          selectedTab = index;
        }),
        color: Colors.white,
        fillColor: PRIMARY_COLOR,
        selectedColor: Colors.white,
        selectedBorderColor: PRIMARY_COLOR,
        borderColor: PRIMARY_COLOR_DARK,
        borderWidth: 1,
        constraints: BoxConstraints(maxHeight: 40),
        children: tabs.map((tab) {
          return Container(
            color: tabs.indexOf(tab) == selectedTab ? PRIMARY_COLOR : PRIMARY_COLOR_DARK,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            alignment: Alignment.center,
            child: Text(tab, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          );
        }).toList(),
      ),
    );
  }

  Widget buildSelectedTab() {
    Widget currentSection = selectedTab == 0
        ? UserReviewsContent(user: user)
        : selectedTab == 1
        ? Container()
        : UserLikesContent(user: user);

    return Expanded(
      child: Container(
        decoration: BoxDecoration(color: TERTIARY_COLOR),
        width: double.infinity,
        child: currentSection,
      ),
    );
  }
}
