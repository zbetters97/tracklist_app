import 'package:flutter/material.dart';
import 'package:tracklist_app/features/user/models/app_user_class.dart';
import 'package:tracklist_app/features/auth/services/auth_service.dart';

ValueNotifier<int> selectedPageNotifier = ValueNotifier(0);
ValueNotifier<double> ratingNotifier = ValueNotifier(0.0);

// Holds the instance of the current user and the auth service
ValueNotifier<AuthService> authService = ValueNotifier(AuthService());
ValueNotifier<AppUser?> authUser = ValueNotifier<AppUser?>(null);
