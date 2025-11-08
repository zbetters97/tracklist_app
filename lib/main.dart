import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tracklist_app/app/widget_tree.dart';
import 'package:tracklist_app/core/constants/constants.dart';
import 'package:tracklist_app/app/config/firebase_options.dart';
import 'package:tracklist_app/core/utils/notifiers.dart';
import 'package:tracklist_app/core/widgets/loading_icon.dart';
import 'package:tracklist_app/features/welcome/pages/welcome_page.dart';

void main() async {
  // Initialize Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await Hive.initFlutter();
  await Hive.openBox('user_settings');

  // Initialize Firebase
  await Firebase.initializeApp();

  runApp(const TrackList());
}

class TrackList extends StatefulWidget {
  const TrackList({super.key});

  @override
  State<TrackList> createState() => _TrackListState();
}

class _TrackListState extends State<TrackList> {
  bool isLoading = true;
  bool isSignedIn = false;

  @override
  void initState() {
    super.initState();
    fetchAuthUser();
  }

  void fetchAuthUser() async {
    setState(() => isLoading = true);

    // Check if user is already logged in
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      bool fetchedSignIn = await authService.value.getAuthUser(currentUser);
      setState(() => isSignedIn = fetchedSignIn);
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return LoadingIcon();
    }

    return MaterialApp(
      title: 'TrackList',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: "Inter",
        colorScheme: ColorScheme.fromSeed(seedColor: PRIMARY_COLOR, brightness: Brightness.dark),
      ),
      home: isSignedIn ? WidgetTree() : WelcomePage(),
    );
  }
}
