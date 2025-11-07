import 'package:flutter/material.dart';
import 'package:tracklist_app/core/widgets/empty_text.dart';
import 'package:tracklist_app/features/auth/models/app_user_class.dart';
import 'package:tracklist_app/features/media/models/media_class.dart';
import 'package:tracklist_app/features/media/services/spotify_service.dart';
import 'package:tracklist_app/features/media/pages/media_page.dart';
import 'package:tracklist_app/features/media/widgets/media_card_widget.dart';
import 'package:tracklist_app/features/user/services/user_service.dart';
import 'package:tracklist_app/features/user/widgets/user_card_widget.dart';
import 'package:tracklist_app/navigation/navigator.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _formKey = GlobalKey<FormState>();

  String selectedCategory = "artist";
  TextEditingController searchController = TextEditingController();

  List<Media> mediaResults = [];
  List<AppUser> userResults = [];

  Future<void> onSearchPressed() async {
    if (searchController.text.isEmpty) return;

    if (selectedCategory == "user") {
      final List<AppUser> users = await searchUsers(searchController.text);
      if (users.isEmpty) return;

      userResults.clear();
      for (final AppUser user in users) {
        setState(() => userResults.add(user));
      }
    } else {
      final List<Media> media = await searchByCategory(selectedCategory, searchController.text);
      if (media.isEmpty) return;

      mediaResults.clear();
      for (final Media item in media) {
        setState(() => mediaResults.add(item));
      }
    }
  }

  void sendToMediaPage(BuildContext context, Media media) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => MediaPage(media: media)));
  }

  @override
  void dispose() {
    searchController.dispose();
    mediaResults.clear();
    userResults.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildSearchBar(),
            const SizedBox(height: 10),
            buildCategoryDropdown(),
            const SizedBox(height: 10),
            Expanded(
              child: selectedCategory == "user" ? buildUserResults(userResults) : buildMediaResults(mediaResults),
            ),
          ],
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
      onFieldSubmitted: (_) => onSearchPressed(),
    );
  }

  Widget buildCategoryDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(border: Border.all(color: Colors.white)),
      child: DropdownButton(
        items: [
          DropdownMenuItem(value: "artist", child: Text("Artist")),
          DropdownMenuItem(value: "album", child: Text("Album")),
          DropdownMenuItem(value: "track", child: Text("Track")),
          DropdownMenuItem(value: "user", child: Text("User")),
        ],
        underline: SizedBox(),
        style: TextStyle(fontSize: 20),
        value: selectedCategory,
        onChanged: (value) => {
          setState(() {
            selectedCategory = value!;
            onSearchPressed();
          }),
        },
      ),
    );
  }

  Widget buildMediaResults(List<Media> results) {
    if (results.isEmpty) {
      return searchController.text == "" ? Container() : EmptyText(message: "No media found!");
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final result = results[index];
        return Center(
          child: GestureDetector(
            onTap: () => NavigationService().openMedia(result),
            child: MediaCardWidget(media: result),
          ),
        );
      },
    );
  }

  Widget buildUserResults(List<AppUser> results) {
    if (results.isEmpty) {
      return searchController.text == "" ? Container() : EmptyText(message: "No users found!");
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final result = results[index];
        return Center(child: UserCardWidget(user: result));
      },
    );
  }
}
