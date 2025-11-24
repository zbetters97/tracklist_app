import 'package:flutter/material.dart';
import 'package:tracklist_app/core/widgets/empty_text.dart';
import 'package:tracklist_app/features/user/models/app_user_class.dart';
import 'package:tracklist_app/features/media/models/media_class.dart';
import 'package:tracklist_app/features/media/services/spotify_service.dart';
import 'package:tracklist_app/features/media/widgets/rated_media_card_widget.dart';
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

  String _selectedCategory = "artist";
  final TextEditingController _searchController = TextEditingController();

  final List<Media> _mediaResults = [];
  final List<AppUser> _userResults = [];

  @override
  void dispose() {
    _searchController.dispose();
    _mediaResults.clear();
    _userResults.clear();
    super.dispose();
  }

  Future<void> _onSearchPressed() async {
    if (_searchController.text.isEmpty) return;

    if (_selectedCategory == "user") {
      await _fetchUsers();
    } else {
      await _fetchMedia();
    }
  }

  Future<void> _fetchUsers() async {
    final List<AppUser> users = await searchUsers(_searchController.text);
    if (users.isEmpty) return;

    _userResults.clear();
    for (final AppUser user in users) {
      setState(() => _userResults.add(user));
    }
  }

  Future<void> _fetchMedia() async {
    final List<Media> media = await searchByCategory(_selectedCategory, _searchController.text);
    if (media.isEmpty) return;

    _mediaResults.clear();
    for (final Media item in media) {
      setState(() => _mediaResults.add(item));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 8.0,
          children: [
            _buildSearchBar(),
            _buildCategoryDropdown(),
            Expanded(
              child: _selectedCategory == "user" ? _buildUserResults(_userResults) : _buildMediaResults(_mediaResults),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextFormField(
      controller: _searchController,
      style: TextStyle(fontSize: 20),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        border: OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        prefixIcon: Icon(Icons.search),
        suffixIcon: IconButton(icon: Icon(Icons.arrow_forward), onPressed: () => _onSearchPressed()),
      ),
      onFieldSubmitted: (_) => _onSearchPressed(),
    );
  }

  Widget _buildCategoryDropdown() {
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
        value: _selectedCategory,
        onChanged: (value) => {
          setState(() {
            _selectedCategory = value!;
            _onSearchPressed();
          }),
        },
      ),
    );
  }

  Widget _buildMediaResults(List<Media> results) {
    if (results.isEmpty) {
      return _searchController.text == "" ? Container() : EmptyText(message: "No media found!");
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final result = results[index];
        return Center(
          child: GestureDetector(
            onTap: () => NavigationService().openMedia(result),
            child: RatedMediaCardWidget(media: result),
          ),
        );
      },
    );
  }

  Widget _buildUserResults(List<AppUser> results) {
    if (results.isEmpty) {
      return _searchController.text == "" ? Container() : EmptyText(message: "No users found!");
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
