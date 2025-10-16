import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:tracklist_app/data/constants.dart';
import 'package:tracklist_app/services/firebase_options.dart';
import 'package:tracklist_app/views/pages/welcome/welcome_page.dart';

void main() async {
  // Initialize Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrackList',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: "Inter",
        colorScheme: ColorScheme.fromSeed(seedColor: PRIMARY_COLOR, brightness: Brightness.dark),
      ),
      home: WelcomePage(),
    );
  }
}
