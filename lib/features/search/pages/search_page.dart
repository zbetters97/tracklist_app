import 'package:flutter/material.dart';
import 'package:tracklist_app/features/media/models/media_class.dart';
import 'package:tracklist_app/features/media/services/spotify_service.dart';
import 'package:tracklist_app/features/media/pages/media_page.dart';
import 'package:tracklist_app/features/media/widgets/media_card_widget.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key, required this.onOpenMedia});

  // Callback to open the media page
  final void Function(Media media) onOpenMedia;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _formKey = GlobalKey<FormState>();

  String selectedCategory = "artist";
  TextEditingController searchController = TextEditingController(text: "Hippo Campus");

  List<Media> results = [];

  Future<void> onSearchPressed() async {
    if (searchController.text.isEmpty) return;

    results.clear();

    String categoryQuery = selectedCategory;
    String mediaQuery = searchController.text;

    final List<Media> media = await searchByCategory(categoryQuery, mediaQuery);

    if (media.isEmpty) return;

    for (final Media item in media) {
      setState(() => results.add(item));
    }
  }

  void sendToMediaPage(BuildContext context, Media media) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return MediaPage(media: media);
        },
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
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
            Expanded(child: buildSearchResults(results)),
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
        suffixIcon: IconButton(icon: Icon(Icons.arrow_forward), onPressed: () => {onSearchPressed()}),
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

  Widget buildSearchResults(List<Media> searchList) {
    return searchList.isEmpty
        ? searchController.text == ""
              ? Center(child: Text(""))
              : Center(child: Text("No results"))
        : ListView.builder(
            itemCount: searchList.length,
            itemBuilder: (context, index) {
              final result = searchList[index];
              return Center(
                child: GestureDetector(
                  onTap: () => widget.onOpenMedia(result),
                  child: MediaCardWidget(media: result),
                ),
              );
            },
          );
  }
}
