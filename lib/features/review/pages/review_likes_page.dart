import 'package:flutter/material.dart';
import 'package:tracklist_app/core/constants/constants.dart';
import 'package:tracklist_app/core/widgets/default_app_bar.dart';
import 'package:tracklist_app/core/widgets/empty_text.dart';
import 'package:tracklist_app/core/widgets/loading_icon.dart';
import 'package:tracklist_app/features/user/models/app_user_class.dart';
import 'package:tracklist_app/features/review/models/review_class.dart';
import 'package:tracklist_app/features/review/services/review_service.dart';
import 'package:tracklist_app/features/user/widgets/user_card_widget.dart';

class ReviewLikesPage extends StatefulWidget {
  final Review review;
  const ReviewLikesPage({super.key, required this.review});

  @override
  State<ReviewLikesPage> createState() => _ReviewLikesPageState();
}

class _ReviewLikesPageState extends State<ReviewLikesPage> {
  bool _isLoading = true;
  List<AppUser> _users = [];
  List<AppUser> _filteredUsers = [];
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  void _fetchUsers() async {
    setState(() => _isLoading = true);

    List<AppUser> fetchedUsers = await getReviewLikeUsers(widget.review.reviewId);

    setState(() {
      _users = fetchedUsers;
      _filteredUsers = fetchedUsers;
      _isLoading = false;
    });
  }

  void _onSearchPressed() {
    final query = searchController.text.toLowerCase();

    if (query.trim().isEmpty) {
      setState(() => _filteredUsers = _users);
    }

    setState(() {
      _filteredUsers = _users.where((user) {
        final String username = user.username.toLowerCase();
        final String displayName = user.displayname.toLowerCase();

        // Check if the username or display name contains the query
        return username.contains(query) || displayName.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultAppBar(title: "Likes"),
      backgroundColor: BACKGROUND_COLOR,
      body: SingleChildScrollView(
        child: _isLoading
            ? LoadingIcon()
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(spacing: 16.0, children: [_buildSearchBar(), _buildUsersList(_users)]),
              ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextFormField(
      controller: searchController,
      style: TextStyle(fontSize: 20),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        border: OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        prefixIcon: Icon(Icons.search),
        suffixIcon: IconButton(icon: Icon(Icons.arrow_forward), onPressed: () => _onSearchPressed()),
      ),
      onChanged: (_) => _onSearchPressed(),
      onFieldSubmitted: (_) => _onSearchPressed(),
    );
  }

  Widget _buildUsersList(List<AppUser> users) {
    if (users.isEmpty) {
      return EmptyText(message: "No likes yet!");
    }

    if (searchController.text.trim().isNotEmpty && _filteredUsers.isEmpty) {
      return EmptyText(message: "No users found!");
    }

    if (_filteredUsers.isNotEmpty) {
      return Column(
        spacing: 12.0,
        children: _filteredUsers.map((user) => UserCardWidget(key: ValueKey(user.uid), user: user)).toList(),
      );
    }

    return Column(
      spacing: 12.0,
      children: users.map((user) => UserCardWidget(key: ValueKey(user.uid), user: user)).toList(),
    );
  }
}
