import 'package:flutter/material.dart';

class UserAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onLogoutPressed;

  const UserAppBar({super.key, required this.onLogoutPressed});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: Colors.white,
      leading: IconButton(onPressed: () {}, icon: Icon(Icons.settings), padding: EdgeInsets.all(20.0)),
      actions: [
        IconButton(onPressed: () => onLogoutPressed(), icon: Icon(Icons.logout), padding: EdgeInsets.all(20.0)),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
