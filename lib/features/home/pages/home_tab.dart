import 'package:flutter/material.dart';
import 'package:tracklist_app/features/error/pages/error_page.dart';
import 'package:tracklist_app/features/home/pages/home_page.dart';
import 'package:tracklist_app/features/media/models/media_class.dart';
import 'package:tracklist_app/features/review/pages/review_add_page.dart';
import 'package:tracklist_app/features/review/pages/review_page.dart';
import 'package:tracklist_app/features/user/pages/user_page.dart';
import 'package:tracklist_app/navigation/navigator.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final navigationService = NavigationService();

    return Navigator(
      key: navigationService.homeNavigatorKey,
      initialRoute: "/",
      onGenerateRoute: (settings) {
        Widget page;

        switch (settings.name) {
          case "/":
            page = HomePage();
            break;
          case "/review":
            page = ReviewPage(reviewId: settings.arguments as String);
            break;
          case "/add":
            page = ReviewAddPage(media: settings.arguments as Media?);
            break;
          case "/user":
            page = UserPage(uid: settings.arguments as String);
            break;
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
