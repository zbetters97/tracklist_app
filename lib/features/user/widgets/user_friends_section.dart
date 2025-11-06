import 'package:flutter/material.dart';
import 'package:tracklist_app/core/constants/constants.dart';
import 'package:tracklist_app/core/widgets/empty_text.dart';
import 'package:tracklist_app/core/widgets/loading_icon.dart';
import 'package:tracklist_app/features/auth/models/app_user_class.dart';
import 'package:tracklist_app/features/user/services/user_service.dart';
import 'package:tracklist_app/features/user/widgets/user_card_widget.dart';

class UserFriendsSection extends StatefulWidget {
  final AppUser user;

  const UserFriendsSection({super.key, required this.user});

  @override
  State<UserFriendsSection> createState() => _UserFriendsSectionState();
}

class _UserFriendsSectionState extends State<UserFriendsSection> {
  AppUser get user => widget.user;
  List<AppUser> following = [];
  List<AppUser> followers = [];
  bool isLoading = true;

  int currentTab = 0;

  final ScrollController friendsController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchFriends();
  }

  void fetchFriends() async {
    setState(() => isLoading = true);

    List<AppUser> fetchedFollowing = await getFollowingByUserId(user.uid);
    List<AppUser> fetchedFollowers = await getFollowersByUserId(user.uid);

    if (!mounted) return;

    setState(() {
      following = fetchedFollowing;
      followers = fetchedFollowers;
      isLoading = false;
    });
  }

  @override
  void dispose() {
    friendsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? LoadingIcon()
        : Column(children: [buildTopBar(), buildUsersList(currentTab == 0 ? followers : following)]);
  }

  Widget buildTopBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [buildFriendTab(0, "Followers"), SizedBox(width: 30), buildFriendTab(1, "Following")],
      ),
    );
  }

  Widget buildFriendTab(int index, String title) {
    return GestureDetector(
      onTap: () => setState(() => currentTab = index),
      child: Text(
        title,
        style: TextStyle(
          color: currentTab == index ? PRIMARY_COLOR : Colors.grey,
          fontSize: 24.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget buildUsersList(List<AppUser> users) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: users.isEmpty
            ? EmptyText(message: currentTab == 0 ? "No followers yet!" : "No one followed yet!")
            : ListView.separated(
                controller: friendsController,
                shrinkWrap: true,
                padding: const EdgeInsets.all(0.0),
                itemCount: users.length,
                itemBuilder: (context, index) => UserCardWidget(user: users[index]),
                separatorBuilder: (context, index) => const SizedBox(height: 16.0),
              ),
      ),
    );
  }
}
