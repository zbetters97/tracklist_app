import 'package:flutter/material.dart';
import 'package:tracklist_app/core/constants/constants.dart';
import 'package:tracklist_app/core/widgets/default_app_bar.dart';
import 'package:tracklist_app/core/widgets/empty_text.dart';
import 'package:tracklist_app/core/widgets/loading_icon.dart';
import 'package:tracklist_app/features/user/models/app_user_class.dart';
import 'package:tracklist_app/features/user/services/user_service.dart';
import 'package:tracklist_app/features/user/widgets/user_card_widget.dart';

class UserFriendsPage extends StatefulWidget {
  final AppUser user;
  final bool isFollowers;
  const UserFriendsPage({super.key, required this.user, required this.isFollowers});

  @override
  State<UserFriendsPage> createState() => _UserFriendsPageState();
}

class _UserFriendsPageState extends State<UserFriendsPage> {
  bool isLoading = true;
  AppUser get user => widget.user;
  List<AppUser> users = [];
  List<AppUser> filteredUsers = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchFriends();
  }

  void fetchFriends() async {
    setState(() => isLoading = true);

    List<AppUser> fetchedUsers = widget.isFollowers
        ? await getFollowersByUserId(user.uid)
        : await getFollowingByUserId(user.uid);

    setState(() {
      users = fetchedUsers;
      filteredUsers = fetchedUsers;
      isLoading = false;
    });
  }

  void onSearchPressed() {
    final query = searchController.text.toLowerCase();

    if (query.trim().isEmpty) {
      setState(() => filteredUsers = users);
    }

    setState(() {
      filteredUsers = users.where((user) {
        final String username = user.username.toLowerCase();
        final String displayName = user.displayname.toLowerCase();

        // Check if the username or display name contains the query
        return username.contains(query) || displayName.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    String title = widget.isFollowers ? "Followers" : "Following";

    return Scaffold(
      appBar: DefaultAppBar(title: title),
      backgroundColor: BACKGROUND_COLOR,
      body: SingleChildScrollView(
        child: isLoading
            ? LoadingIcon()
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(spacing: 16.0, children: [buildSearchBar(), buildUsersList(users)]),
              ),
      ),
    );
  }

  Widget buildSearchBar() {
    return TextFormField(
      controller: searchController,
      style: TextStyle(fontSize: 20),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        border: OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        prefixIcon: Icon(Icons.search),
        suffixIcon: IconButton(icon: Icon(Icons.arrow_forward), onPressed: () => onSearchPressed()),
      ),
      onChanged: (_) => onSearchPressed(),
      onFieldSubmitted: (_) => onSearchPressed(),
    );
  }

  Widget buildUsersList(List<AppUser> users) {
    String message = widget.isFollowers ? "No followers yet!" : "No one followed yet!";
    if (users.isEmpty) {
      return EmptyText(message: message);
    }

    if (searchController.text.trim().isNotEmpty && filteredUsers.isEmpty) {
      return EmptyText(message: "No users found!");
    }

    if (filteredUsers.isNotEmpty) {
      return Column(
        spacing: 12.0,
        children: filteredUsers.map((user) => UserCardWidget(key: ValueKey(user.uid), user: user)).toList(),
      );
    }

    return Column(
      spacing: 12.0,
      children: users.map((user) => UserCardWidget(key: ValueKey(user.uid), user: user)).toList(),
    );
  }
}
