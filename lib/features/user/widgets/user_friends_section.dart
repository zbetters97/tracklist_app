import 'package:flutter/material.dart';
import 'package:tracklist_app/core/constants/constants.dart';
import 'package:tracklist_app/features/auth/models/app_user_class.dart';
import 'package:tracklist_app/features/auth/services/auth_service.dart';
import 'package:tracklist_app/features/user/widgets/user_card.dart';

class UserFriendsSection extends StatefulWidget {
  const UserFriendsSection({super.key, required this.user});

  final AppUser user;

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

    List<AppUser> fetchedFollowing = await authService.value.getFollowingByUserId(user.uid);
    List<AppUser> fetchedFollowers = await authService.value.getFollowersByUserId(user.uid);

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
        ? const Center(child: CircularProgressIndicator(color: PRIMARY_COLOR_DARK))
        : Column(children: [buildTopBar(), currentTab == 0 ? buildUserFollowers() : buildUserFollowing()]);
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
      onTap: () {
        setState(() => currentTab = index);
      },
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

  Widget buildUserFollowing() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.separated(
          controller: friendsController,
          shrinkWrap: true,
          padding: const EdgeInsets.all(0.0),
          itemCount: following.length,
          itemBuilder: (context, index) {
            return UserCard(user: following[index]);
          },
          separatorBuilder: (context, index) => const SizedBox(height: 16.0),
        ),
      ),
    );
  }

  Widget buildUserFollowers() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.separated(
          controller: friendsController,
          shrinkWrap: true,
          padding: const EdgeInsets.all(0.0),
          itemCount: followers.length,
          itemBuilder: (context, index) {
            return UserCard(user: followers[index]);
          },
          separatorBuilder: (context, index) => const SizedBox(height: 16.0),
        ),
      ),
    );
  }
}
