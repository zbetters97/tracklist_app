import 'package:flutter/material.dart';
import 'package:tracklist_app/core/utils/notifiers.dart';
import 'package:tracklist_app/features/media/models/media_class.dart';

class NavigationService {
  NavigationService._privateConstructor();
  static final NavigationService _instance = NavigationService._privateConstructor();
  factory NavigationService() => _instance;

  // Navigator keys
  final GlobalKey<NavigatorState> homeNavigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> searchNavigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> userNavigatorKey = GlobalKey<NavigatorState>();

  static const int homeTabIndex = 0;
  static const int searchTabIndex = 1;
  static const int userTabIndex = 4;

  GlobalKey<NavigatorState>? _getNavigatorKey(int tabIndex) {
    if (tabIndex == homeTabIndex) return homeNavigatorKey;
    if (tabIndex == searchTabIndex) return searchNavigatorKey;
    if (tabIndex == userTabIndex) return userNavigatorKey;

    return null;
  }

  void openReview(String reviewId) {
    final navigatorKey = _getNavigatorKey(selectedPageNotifier.value);
    navigatorKey?.currentState?.pushNamed("/review", arguments: reviewId);
  }

  void openUser(String userId) {
    final navigatorKey = _getNavigatorKey(selectedPageNotifier.value);
    navigatorKey?.currentState?.pushNamed("/user", arguments: userId);
  }

  void openMedia(Media media) {
    final navigatorKey = _getNavigatorKey(selectedPageNotifier.value);
    navigatorKey?.currentState?.pushNamed("/media", arguments: media);
  }
}
