import 'package:flutter/material.dart';
import 'package:tracklist_app/data/constants.dart';
import 'package:tracklist_app/services/auth_service.dart';
import 'package:tracklist_app/views/widgets/my_app_bar.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key, required this.uid});

  final String uid;

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  bool isLoading = true;
  Map<String, dynamic> user = {};

  @override
  void initState() {
    super.initState();
    fetchUser();
  }

  void fetchUser() async {
    isLoading = true;

    Map<String, dynamic> tempUser = await authService.value.getUserById(userId: widget.uid);

    setState(() {
      user = tempUser;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator(color: PRIMARY_COLOR_DARK));

    return Scaffold(
      appBar: MyAppBar(title: user["username"] ?? "User"),
      body: Center(child: Column(children: [Text(user["displayname"] ?? ""), Text(widget.uid)])),
      backgroundColor: BACKGROUND_COLOR,
    );
  }
}
