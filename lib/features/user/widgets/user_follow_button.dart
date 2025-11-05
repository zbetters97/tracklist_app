import 'package:flutter/material.dart';
import 'package:tracklist_app/core/constants/constants.dart';
import 'package:tracklist_app/features/auth/models/app_user_class.dart';
import 'package:tracklist_app/features/auth/services/auth_service.dart';

class UserFollowButton extends StatefulWidget {
  const UserFollowButton({super.key, required this.user, required this.onFollowChanged});

  final AppUser user;
  final void Function(bool isFollowing) onFollowChanged;

  @override
  State<UserFollowButton> createState() => _UserFollowButtonState();
}

class _UserFollowButtonState extends State<UserFollowButton> {
  AppUser get user => widget.user;
  bool isFollowing = false;

  @override
  void initState() {
    super.initState();

    setState(() {
      isFollowing = user.followers.contains(authUser.value!.uid);
    });
  }

  void onFollowPressed() async {
    if (isFollowing) {
      await authService.value.unfollowUser(userId: user.uid);
    } else {
      await authService.value.followUser(userId: user.uid);
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
