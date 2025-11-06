import 'package:flutter/material.dart';
import 'package:tracklist_app/core/constants/constants.dart';
import 'package:tracklist_app/core/utils/notifiers.dart';
import 'package:tracklist_app/features/auth/models/app_user_class.dart';
import 'package:tracklist_app/features/user/services/user_service.dart';

class UserFollowButton extends StatefulWidget {
  final AppUser user;
  final void Function(bool isFollowing) onFollowChanged;

  const UserFollowButton({super.key, required this.user, required this.onFollowChanged});

  @override
  State<UserFollowButton> createState() => _UserFollowButtonState();
}

class _UserFollowButtonState extends State<UserFollowButton> {
  AppUser get user => widget.user;
  bool isFollowing = false;

  @override
  void initState() {
    super.initState();
    setState(() => isFollowing = user.followers.contains(authUser.value!.uid));
  }

  void onFollowPressed() async {
    if (isFollowing) {
      await unfollowUser(userId: user.uid);
    } else {
      await followUser(userId: user.uid);
    }

    widget.onFollowChanged(isFollowing);

    if (!mounted) return;

    setState(() => isFollowing = !isFollowing);
  }

  @override
  void dispose() {
    isFollowing = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () => onFollowPressed(),
          style: ElevatedButton.styleFrom(
            backgroundColor: PRIMARY_COLOR_DARK,
            shape: RoundedRectangleBorder(),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          ),
          child: Text(
            isFollowing ? "Following" : "Follow",
            style: TextStyle(color: Colors.white, fontSize: 16.0, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
