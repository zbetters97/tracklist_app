import 'package:flutter/material.dart';
import 'package:tracklist_app/data/models/review_class.dart';
import 'package:tracklist_app/features/home/pages/home_page.dart';
import 'package:tracklist_app/features/review/pages/review_page.dart';
import 'package:tracklist_app/navigation/nav_item_widget.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: homeNavigatorKey,
      initialRoute: "/", // Default route to Home Page
      onGenerateRoute: (settings) {
        Widget page;

        switch (settings.name) {
          // Open Home Page when routed
          case "/":
            page = HomePage(
              onOpenReview: (review) {
                homeNavigatorKey.currentState!.pushNamed("/review", arguments: review);
              },
            );
            break;
          // Open Review Page when a review is clicked
          case "/review":
            Review review = settings.arguments as Review;
            page = ReviewPage(reviewId: review.reviewId);
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
