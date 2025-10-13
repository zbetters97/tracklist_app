import 'package:flutter/material.dart';
import 'package:tracklist_app/views/pages/home/home_page.dart';
import 'package:tracklist_app/views/pages/review/review_page.dart';

class HomeTab extends StatelessWidget {
  HomeTab({super.key});

  // Used to navigate between pages
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      initialRoute: "/", // Default route to Home Page
      onGenerateRoute: (settings) {
        Widget page;

        switch (settings.name) {
          // Open Home Page when routed
          case "/":
            page = HomePage(
              onOpenReview: (review) {
                navigatorKey.currentState!.pushNamed("/review", arguments: review);
              },
            );
            break;
          // Open Review Page when a review is clicked
          case "/review":
            page = ReviewPage(review: settings.arguments as Map<String, dynamic>);
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
