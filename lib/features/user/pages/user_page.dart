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
  bool _isLoading = true;
  late AppUser user;
  bool _isLoggedInUser = false;

  final List<String> _tabs = ["Reviews", "Lists", "Likes"];
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  @override
  void dispose() {
    _isLoading = false;
    super.dispose();
  }

  void _fetchUser() async {
    setState(() => _isLoading = true);

    // If no passed uid, get current user's uid
    String uid = widget.uid == "" ? authUser.value!.uid : widget.uid;

    if (!mounted) return;

    _isLoggedInUser = uid == authUser.value!.uid;

    // User is on their own profile, highlight Profile tab
    if (_isLoggedInUser) {
      // Wait for _build to finish
      WidgetsBinding.instance.addPostFrameCallback((_) {
        selectedPageNotifier.value = 4;
      });
      setState(() => user = authUser.value!);
    } else {
      AppUser fetchedUser = await getUserById(userId: uid);
      setState(() => user = fetchedUser);
    }

    if (!mounted) return;

    setState(() => _isLoading = false);
  }

  void _onFollowChanged(bool isFollowing) {
    setState(() {
      if (isFollowing) {
        user.followers.remove(authUser.value!.uid);
      } else {
        user.followers.add(authUser.value!.uid);
      }
    });
  }

  void _onLogoutPressed() {
    authService.value.signOut();

    // Reset selected page
    selectedPageNotifier.value = 0;

    Navigator.of(
      context,
      rootNavigator: true,
    ).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const WelcomePage()), (route) => false);
  }

  void _sendToFriendsPage(bool isFollowers) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserFriendsPage(user: user, isFollowers: isFollowers),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return LoadingIcon();
    }

    return Scaffold(
      appBar: _isLoggedInUser ? UserAppBar(onLogoutPressed: _onLogoutPressed) : DefaultAppBar(title: ""),
      backgroundColor: BACKGROUND_COLOR,
      extendBodyBehindAppBar: true,
      body: __buildUserProfile(),
    );
  }

  Widget __buildUserProfile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 3.0,
            children: [
              _buildProfile(),
              _buildBio(),
              _buildDate(),
              _buildFriends(),
              if (!_isLoggedInUser) UserFollowButton(user: user, onFollowChanged: _onFollowChanged),
            ],
          ),
        ),
        _buildUserTabs(),
        _buildSelectedTab(),
      ],
    );
  }

  Widget _buildProfile() {
    return Column(children: [user.buildProfileImage(context, 50.0), _buildUsername()]);
  }

  Widget _buildUsername() {
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

  Widget _buildBio() {
    if (user.bio == "") {
      return Container();
    }

    return Text(
      user.bio,
      style: const TextStyle(color: Colors.white, fontSize: 18, fontStyle: FontStyle.italic),
    );
  }

  Widget _buildDate() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 2.0,
      children: [
        Icon(Icons.calendar_today, color: Colors.grey, size: 18),
        Text("Joined on ${formatDateMDYLong(user.createdAt)}", style: TextStyle(fontSize: 16)),
      ],
    );
  }

  Widget _buildFriends() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 10.0,
      children: [_buildFriendsTab(true), _buildFriendsTab(false)],
    );
  }

  Widget _buildFriendsTab(bool isFollowers) {
    String text = isFollowers ? user.followers.length.toString() : user.following.length.toString();

    return GestureDetector(
      onTap: () => _sendToFriendsPage(isFollowers),
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

  Widget _buildUserTabs() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: ToggleButtons(
        isSelected: List.generate(_tabs.length, (index) => index == _selectedTab),
        onPressed: (index) => setState(() {
          _selectedTab = index;
        }),
        color: Colors.white,
        fillColor: PRIMARY_COLOR,
        selectedColor: Colors.white,
        selectedBorderColor: PRIMARY_COLOR,
        borderColor: PRIMARY_COLOR_DARK,
        borderWidth: 1,
        constraints: BoxConstraints(maxHeight: 40),
        children: _tabs.map((tab) {
          return Container(
            color: _tabs.indexOf(tab) == _selectedTab ? PRIMARY_COLOR : PRIMARY_COLOR_DARK,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            alignment: Alignment.center,
            child: Text(tab, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSelectedTab() {
    Widget currentSection = _selectedTab == 0
        ? UserReviewsContent(user: user)
        : _selectedTab == 1
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
