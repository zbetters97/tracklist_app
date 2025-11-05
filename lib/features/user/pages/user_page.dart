import 'package:flutter/material.dart';
import 'package:tracklist_app/features/auth/models/app_user_class.dart';
import 'package:tracklist_app/core/constants/constants.dart';
import 'package:tracklist_app/core/utils/date.dart';
import 'package:tracklist_app/core/utils/notifiers.dart';
import 'package:tracklist_app/core/extensions/string_extensions.dart';
import 'package:tracklist_app/features/auth/services/auth_service.dart';
import 'package:tracklist_app/features/user/widgets/user_follow_button.dart';
import 'package:tracklist_app/features/user/widgets/user_friends_section.dart';
import 'package:tracklist_app/features/user/widgets/user_reviews_section.dart';
import 'package:tracklist_app/features/welcome/pages/welcome_page.dart';
import 'package:tracklist_app/core/widgets/default_app_bar.dart';
import 'package:tracklist_app/features/user/widgets/user_app_bar.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key, this.uid = ""});

  final String uid;

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  bool isLoading = true;
  late AppUser user;
  bool isLoggedInUser = false;

  final List<String> tabs = ["Reviews", "Lists", "Likes", "Friends"];
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
      selectedPageNotifier.value = 4;
      setState(() => user = authUser.value!);
    } else {
      AppUser fetchedUser = await authService.value.getUserById(userId: uid);
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
      rootNavigator: true, // Top-level navigator is used
    ).pushAndRemoveUntil(
      // Removes all previous pages in the stack
      MaterialPageRoute(builder: (context) => const WelcomePage()),
      (route) => false,
    );
  }

  @override
  void dispose() {
    isLoading = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator(color: PRIMARY_COLOR_DARK))
        : Scaffold(
            appBar: isLoggedInUser
                ? UserAppBar(user: user, onLogoutPressed: onLogoutPressed)
                : DefaultAppBar(title: ""),
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
                      buildFriends(user.followers.length, user.following.length),
                      const SizedBox(height: 4),
                      if (!isLoggedInUser) UserFollowButton(user: user, onFollowChanged: onFollowChanged),
                    ],
                  ),
                ),
                buildUserTabs(),
                buildSelectedTab(),
              ],
            ),
          );
  }

  Widget buildSelectedTab() {
    Widget currentSection = selectedTab == 0
        ? UserReviewsSection(user: user)
        : selectedTab == 1
        ? Container()
        : selectedTab == 2
        ? Container()
        : UserFriendsSection(user: user);

    return Expanded(
      child: Container(
        decoration: BoxDecoration(color: TERTIARY_COLOR),
        width: double.infinity,
        child: currentSection,
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
            Text(
              user.displayname.capitalizeEachWord(),
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
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
}
