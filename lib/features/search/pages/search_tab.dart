import 'package:flutter/material.dart';
import 'package:tracklist_app/data/models/media_class.dart';
import 'package:tracklist_app/features/media/pages/media_page.dart';
import 'package:tracklist_app/features/search/pages/search_page.dart';
import 'package:tracklist_app/navigation/nav_item_widget.dart';

class SearchTab extends StatelessWidget {
  const SearchTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: searchNavigatorKey,
      initialRoute: "/", // Default route to Search Page
      onGenerateRoute: (settings) {
        Widget page;

        switch (settings.name) {
          // Open Search Page when routed
          case "/":
            page = SearchPage(
              onOpenMedia: (media) {
                searchNavigatorKey.currentState!.pushNamed("/media", arguments: media);
              },
            );
            break;
          // Open Review Page when a review is clicked
          case "/media":
            page = MediaPage(media: settings.arguments as Media);
            break;
          // Default case
          // TODO: Add default route to Errror Page
          default:
            page = Container();
            break;
        }

        // Return the assigned page
        return MaterialPageRoute(builder: (context) => page, settings: settings);
      },
    );
  }
}
