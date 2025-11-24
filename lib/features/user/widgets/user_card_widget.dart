import 'package:flutter/material.dart';
import 'package:tracklist_app/core/constants/constants.dart';
import 'package:tracklist_app/core/extensions/string_extensions.dart';
import 'package:tracklist_app/core/utils/notifiers.dart';
import 'package:tracklist_app/features/user/models/app_user_class.dart';
import 'package:tracklist_app/features/user/widgets/user_follow_button.dart';
import 'package:tracklist_app/navigation/navigator.dart';

class UserCardWidget extends StatefulWidget {
  final AppUser user;

  const UserCardWidget({super.key, required this.user});

  @override
  State<UserCardWidget> createState() => _UserCardWidgetState();
}

class _UserCardWidgetState extends State<UserCardWidget> {
  AppUser get user => widget.user;

  void _onFollowChanged(bool isFollowing) {
    setState(() {
      if (isFollowing) {
        user.followers.remove(authUser.value!.uid);
      } else {
        user.followers.add(authUser.value!.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => NavigationService().openUser(user.uid),
          child: Row(spacing: 8.0, children: [_buildProfileImage(user.profileUrl), _buildUserInfo(user)]),
        ),
        if (authUser.value!.uid != user.uid) UserFollowButton(user: user, onFollowChanged: _onFollowChanged),
      ],
    );
  }

  Widget _buildProfileImage(String profileUrl) {
    CircleAvatar profileImage = profileUrl.startsWith("https")
        ? CircleAvatar(radius: 24.0, backgroundImage: NetworkImage(profileUrl))
        : CircleAvatar(radius: 24.0, backgroundImage: AssetImage(DEFAULT_PROFILE_IMG));

    return profileImage;
  }

  Widget _buildUserInfo(AppUser user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          user.displayname.capitalizeEachWord(),
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text("@${user.username}", style: TextStyle(color: Colors.grey, fontSize: 16)),
        _buildUserFriends(user),
      ],
    );
  }

  Widget _buildUserFriends(AppUser user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      spacing: 10.0,
      children: [
        Text.rich(
          TextSpan(
            style: TextStyle(color: Colors.grey, fontSize: 16),
            children: [
              TextSpan(
                text: user.followers.length.toString(),
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              TextSpan(text: " followers"),
            ],
          ),
        ),
        Text.rich(
          TextSpan(
            style: TextStyle(color: Colors.grey, fontSize: 16),
            children: [
              TextSpan(
                text: user.following.length.toString(),
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              TextSpan(text: " following"),
            ],
          ),
        ),
      ],
    );
  }
}
