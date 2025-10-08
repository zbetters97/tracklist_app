import 'package:flutter/material.dart';
import 'package:tracklist_app/services/spotify_search.dart';
import 'package:tracklist_app/views/widgets/media_card_widget.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _formKey = GlobalKey<FormState>();

  String selectedCategory = "artist";
  TextEditingController searchController = TextEditingController(text: "Hippo Campus");

  List<Map<String, dynamic>> results = [];

  Future<void> onSearchPressed() async {
    if (searchController.text.isEmpty) return;

    results.clear();

    String categoryQuery = selectedCategory;
    String mediaQuery = searchController.text;

    final List<Map<String, dynamic>> media = await searchByCategory(category: categoryQuery, name: mediaQuery);

    if (media.isEmpty) return;

    for (final Map<String, dynamic> item in media) {
      setState(() {
        results.add(item);
      });
    }
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
            Expanded(
              child: results.isEmpty
                  ? searchController.text == ""
                        ? Center(child: Text(""))
                        : Center(child: Text("No results"))
                  : ListView.builder(
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final result = results[index];
                        return Center(
                          child: MediaCardWidget(name: result["name"], imageUrl: result["image"]),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
