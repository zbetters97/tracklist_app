import 'package:flutter/material.dart';
import 'package:tracklist_app/features/media/models/media_class.dart';

class NavigationService {
  NavigationService._privateConstructor();
  static final NavigationService _instance = NavigationService._privateConstructor();
  factory NavigationService() => _instance;

  // Navigator keys
  final GlobalKey<NavigatorState> homeNavigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> searchNavigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> userNavigatorKey = GlobalKey<NavigatorState>();

  // Tab control
  final ValueNotifier<int> selectedTab = ValueNotifier<int>(0);

  static const int homeTabIndex = 0;
  static const int searchTabIndex = 1;
  static const int userTabIndex = 2;

  // Navigation helpers
  void homeOpenReview(String reviewId) {
    homeNavigatorKey.currentState?.pushNamed("/review", arguments: reviewId);
  }

  void searchOpenMedia(Media media) {
    searchNavigatorKey.currentState?.pushNamed("/media", arguments: media);
  }

  void userOpenUser(String userId) {
    userNavigatorKey.currentState?.pushNamed("/user", arguments: userId);
  }

  void userOpenReview(String reviewId) {
    userNavigatorKey.currentState?.pushNamed("/review", arguments: reviewId);
  }
}
