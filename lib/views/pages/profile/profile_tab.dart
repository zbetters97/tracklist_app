import 'package:flutter/material.dart';
import 'package:tracklist_app/views/pages/profile/profile_page.dart';
import 'package:tracklist_app/views/pages/review/review_page.dart';
import 'package:tracklist_app/views/widgets/nav_item_widget.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: profileNavigatorKey,
      initialRoute: "/",
      onGenerateRoute: (settings) {
        Widget page;
        switch (settings.name) {
          case "/":
            page = ProfilePage(
              onOpenReview: (review) {
                profileNavigatorKey.currentState!.pushNamed("/review", arguments: review);
              },
            );
            break;
          case "/review":
            page = ReviewPage(review: settings.arguments as Map<String, dynamic>);
            break;
          // TODO: Add route to Settings
          default:
            page = Container();
            break;
        }

        return MaterialPageRoute(builder: (context) => page, settings: settings);
      },
    );
  }
}
