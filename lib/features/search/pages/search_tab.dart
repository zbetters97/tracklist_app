import 'package:flutter/material.dart';
import 'package:tracklist_app/features/error/pages/error_page.dart';
import 'package:tracklist_app/features/media/models/media_class.dart';
import 'package:tracklist_app/features/media/pages/media_page.dart';
import 'package:tracklist_app/features/search/pages/search_page.dart';
import 'package:tracklist_app/features/user/pages/user_page.dart';
import 'package:tracklist_app/navigation/navigator.dart';

class SearchTab extends StatelessWidget {
  const SearchTab({super.key});

  @override
  Widget build(BuildContext context) {
    final navigationService = NavigationService();

    return Navigator(
      key: navigationService.searchNavigatorKey,
      initialRoute: "/", // Default route to Search Page
      onGenerateRoute: (settings) {
        Widget page;

        switch (settings.name) {
          // Open Search Page when routed
          case "/":
            page = SearchPage();
            break;
          // Open Review Page when a review is clicked
          case "/media":
            page = MediaPage(media: settings.arguments as Media);
            break;
          case "/user":
            page = UserPage(uid: settings.arguments as String);
            break;
          // Default case
          default:
            page = ErrorPage();
            break;
        }

        // Return the assigned page
        return MaterialPageRoute(builder: (context) => page, settings: settings);
      },
    );
  }
}
