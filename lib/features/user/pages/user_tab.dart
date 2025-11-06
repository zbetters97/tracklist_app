import 'package:flutter/material.dart';
import 'package:tracklist_app/core/utils/notifiers.dart';
import 'package:tracklist_app/features/error/pages/error_page.dart';
import 'package:tracklist_app/features/review/pages/review_page.dart';
import 'package:tracklist_app/features/user/pages/user_page.dart';
import 'package:tracklist_app/navigation/navigator.dart';

class UserTab extends StatelessWidget {
  const UserTab({super.key});

  @override
  Widget build(BuildContext context) {
    final navigationService = NavigationService();

    return Navigator(
      key: navigationService.userNavigatorKey,
      initialRoute: "/",
      onGenerateRoute: (settings) {
        Widget page;

        switch (settings.name) {
          case "/":
            page = UserPage(uid: authUser.value!.uid);
            break;
          case "/user":
            page = UserPage(uid: settings.arguments as String);
            break;
          case "/review":
            page = ReviewPage(reviewId: settings.arguments as String);
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
