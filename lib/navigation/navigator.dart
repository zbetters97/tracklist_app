import 'package:flutter/material.dart';
import 'package:tracklist_app/core/utils/notifiers.dart';
import 'package:tracklist_app/features/media/models/media_class.dart';

class NavigationService {
  NavigationService._privateConstructor();
  static final NavigationService _instance = NavigationService._privateConstructor();
  factory NavigationService() => _instance;

  final GlobalKey<NavigatorState> homeNavigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> searchNavigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> userNavigatorKey = GlobalKey<NavigatorState>();

  static const int _homeTabIndex = 0;
  static const int _searchTabIndex = 1;
  static const int _userTabIndex = 4;

  GlobalKey<NavigatorState>? _getNavigatorKey(int tabIndex) {
    if (tabIndex == _homeTabIndex) return homeNavigatorKey;
    if (tabIndex == _searchTabIndex) return searchNavigatorKey;
    if (tabIndex == _userTabIndex) return userNavigatorKey;

    return null;
  }

  void openReview(String reviewId) {
    final navigatorKey = _getNavigatorKey(selectedPageNotifier.value);
    navigatorKey?.currentState?.pushNamed("/review", arguments: reviewId);
  }

  void openAddReview({Media? media}) {
    final navigatorKey = _getNavigatorKey(selectedPageNotifier.value);
    navigatorKey?.currentState?.pushNamed("/add", arguments: media);
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
