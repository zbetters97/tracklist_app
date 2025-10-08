import 'package:flutter/material.dart';
import 'package:tracklist_app/data/notifiers.dart';
import 'package:tracklist_app/views/widgets/nav_item_widget.dart';

class NavbarWidget extends StatefulWidget {
  const NavbarWidget({super.key});

  @override
  State<NavbarWidget> createState() => _NavbarWidgetState();
}

class _NavbarWidgetState extends State<NavbarWidget> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: selectedPageNotifier,
      builder: (context, selectedPage, child) {
        return NavigationBar(
          destinations: [
            NavitemWidget(icon: Icons.home, index: 0, selectedPage: selectedPage),
            NavitemWidget(icon: Icons.search, index: 1, selectedPage: selectedPage),
            NavitemWidget(icon: Icons.mail_sharp, index: 2, selectedPage: selectedPage),
            NavitemWidget(icon: Icons.notifications, index: 3, selectedPage: selectedPage),
            NavitemWidget(icon: Icons.person, index: 4, selectedPage: selectedPage),
          ],
          onDestinationSelected: (int value) => {selectedPageNotifier.value = value},
          selectedIndex: selectedPage,
          backgroundColor: Colors.black,
        );
      },
    );
  }
}
