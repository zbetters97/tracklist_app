import 'package:flutter/material.dart';
import 'package:tracklist_app/features/error/pages/error_page.dart';
import 'package:tracklist_app/features/home/pages/home_page.dart';
import 'package:tracklist_app/features/review/pages/review_page.dart';
import 'package:tracklist_app/navigation/navigator.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final navigationService = NavigationService();

    return Navigator(
      key: navigationService.homeNavigatorKey,
      initialRoute: "/", // Default route to Home Page
      onGenerateRoute: (settings) {
        Widget page;

        switch (settings.name) {
          // Open Home Page when routed
          case "/":
            page = HomePage();
            break;
          // Open Review Page when a review is clicked
          case "/review":
            page = ReviewPage(reviewId: settings.arguments as String);
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
