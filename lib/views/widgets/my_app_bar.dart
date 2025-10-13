import 'package:flutter/material.dart';
import 'package:tracklist_app/data/constants.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppBar({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return AppBar(title: Text(title), backgroundColor: BACKGROUND_COLOR, elevation: 0);
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
