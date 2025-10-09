import 'package:flutter/material.dart';
import 'package:tracklist_app/data/constants.dart';
import 'package:tracklist_app/data/notifiers.dart';
import 'package:tracklist_app/views/pages/home_page.dart';
import 'package:tracklist_app/views/pages/profile_page.dart';
import 'package:tracklist_app/views/pages/search_page.dart';
import 'package:tracklist_app/views/widgets/navbar_widget.dart';

const List<MapEntry<String, Widget>> pages = [
  MapEntry("Home", HomePage()),
  MapEntry("Search", SearchPage()),
  MapEntry("Chat", SearchPage()),
  MapEntry("Inbox", SearchPage()),
  MapEntry("Profile", ProfilePage()),
];

class WidgetTree extends StatelessWidget {
  const WidgetTree({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: selectedPageNotifier,
      builder: (context, selectedPage, child) {
        final currentPage = pages[selectedPage];

        return Scaffold(
          backgroundColor: BACKGROUND_COLOR,
          body: SafeArea(child: currentPage.value),
          bottomNavigationBar: const NavbarWidget(),
        );
      },
    );
  }
}
