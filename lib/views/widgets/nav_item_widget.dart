import 'package:flutter/material.dart';
import 'package:tracklist_app/data/constants.dart';
import 'package:tracklist_app/data/notifiers.dart';

class NavitemWidget extends StatelessWidget {
  const NavitemWidget({super.key, required this.icon, required this.index, required this.selectedPage});

  final IconData icon;
  final int index;
  final int selectedPage;

  @override
  Widget build(BuildContext context) {
    final bool isCurrentPage = index == selectedPage;

    return Column(
      children: [
        Container(
          height: 5,
          width: 50,
          decoration: BoxDecoration(
            color: isCurrentPage ? PRIMARY_COLOR : Colors.transparent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        IconButton(
          icon: Icon(icon, color: isCurrentPage ? PRIMARY_COLOR : Colors.white, size: 35),
          onPressed: () {
            selectedPageNotifier.value = index;
          },
        ),
      ],
    );
  }
}
