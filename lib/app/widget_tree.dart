import 'package:flutter/material.dart';
import 'package:tracklist_app/core/constants/constants.dart';
import 'package:tracklist_app/core/utils/notifiers.dart';
import 'package:tracklist_app/features/home/pages/home_tab.dart';
import 'package:tracklist_app/features/search/pages/search_tab.dart';
import 'package:tracklist_app/features/user/pages/user_tab.dart';
import 'package:tracklist_app/navigation/navbar_widget.dart';

final List<MapEntry<String, Widget>> pages = [
  MapEntry("Home", HomeTab()),
  MapEntry("Search", SearchTab()),
  MapEntry("Chat", UserTab()),
  MapEntry("Inbox", UserTab()),
  MapEntry("Profile", UserTab()),
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
