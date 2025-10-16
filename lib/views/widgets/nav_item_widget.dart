import 'package:flutter/material.dart';
import 'package:tracklist_app/data/constants.dart';
import 'package:tracklist_app/data/utils/notifiers.dart';

// Used to navigate between pages
final GlobalKey<NavigatorState> homeNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> profileNavigatorKey = GlobalKey<NavigatorState>();

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
            if (index == 0) {
              homeNavigatorKey.currentState?.popUntil((route) => route.isFirst);
            }

            if (index == 4) {
              profileNavigatorKey.currentState?.popUntil((route) => route.isFirst);
            }

            selectedPageNotifier.value = index;
          },
        ),
      ],
    );
  }
}
