import 'package:flutter/material.dart';
import 'package:tracklist_app/core/constants/constants.dart';
import 'package:tracklist_app/core/widgets/default_app_bar.dart';
import 'package:tracklist_app/features/media/models/album_class.dart';
import 'package:tracklist_app/features/media/models/media_class.dart';
import 'package:tracklist_app/features/media/models/track_class.dart';
import 'package:tracklist_app/features/media/services/spotify_service.dart';

class ReviewAddPage extends StatefulWidget {
  const ReviewAddPage({super.key});

  @override
  State<ReviewAddPage> createState() => _ReviewAddPageState();
}

class _ReviewAddPageState extends State<ReviewAddPage> {
  final _formKey = GlobalKey<FormState>();

  Media? media;
  List<Media> suggestions = [];
  String selectedCategory = "artist";
  TextEditingController controllerName = TextEditingController();
  TextEditingController controllerContent = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  void onSearchPressed() async {
    List<Media> fetchedMedia = await searchByCategory(selectedCategory, controllerName.text, limit: 5);

    setState(() {
      suggestions = fetchedMedia;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultAppBar(title: "Add Review"),
      backgroundColor: BACKGROUND_COLOR,
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 16.0,
                children: [buildMediaImage(), buildSearchName(), buildRating(), buildContent(), buildSubmitButton()],
              ),
              buildMediaList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildMediaImage() {
    if (media != null) return media!.buildImage(200);
    return Image.asset(DEFAULT_MEDIA_IMG, width: 200, height: 200, fit: BoxFit.cover);
  }

  Widget buildSearchName() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(flex: 2, child: buildNameField()),
        Expanded(flex: 1, child: buildCategoryDropdown()),
      ],
    );
  }

  Widget buildNameField() {
    String word = selectedCategory == "track" ? "a" : "an";

    return TextFormField(
      controller: controllerName,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        border: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        hintText: "Search for $word $selectedCategory...",
      ),
      onChanged: (value) => onSearchPressed(),
      style: const TextStyle(color: Colors.white, fontSize: 20),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter some text';
        }
        return null;
      },
    );
  }

  Widget buildCategoryDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButton(
        items: [
          DropdownMenuItem(value: "artist", child: Text("Artist")),
          DropdownMenuItem(value: "album", child: Text("Album")),
          DropdownMenuItem(value: "track", child: Text("Track")),
        ],
        underline: SizedBox(),
        style: TextStyle(fontSize: 20),
        value: selectedCategory,
        onChanged: (value) => setState(() => selectedCategory = value!),
      ),
    );
  }

  Widget buildMediaList() {
    if (suggestions.isEmpty) {
      return Container();
    }

    return Positioned(
      left: 0,
      right: 0,
      top: 275,
      child: Material(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          constraints: BoxConstraints(maxHeight: 200),
          color: PRIMARY_COLOR,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: suggestions.length,
            itemBuilder: (context, index) {
              final item = suggestions[index];
              return InkWell(
                onTap: () {
                  setState(() {
                    media = item;
                    controllerName.text = item.name;
                    suggestions = [];
                  });
                },
                child: buildMediaItem(item),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget buildMediaItem(Media media) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          media.name,
          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        if (selectedCategory == "album")
          Text((media as Album).artist, style: const TextStyle(color: Colors.white, fontSize: 16)),
        if (selectedCategory == "track")
          Text((media as Track).artist, style: const TextStyle(color: Colors.white, fontSize: 16)),
      ],
    );
  }

  Widget buildRating() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4.0,
      children: [
        Text("Your rating", style: TextStyle(color: Colors.grey, fontSize: 20)),
        Row(children: [...List.generate(5, (index) => Icon(Icons.star, color: Colors.grey, size: 40))]),
      ],
    );
  }

  Widget buildContent() {
    bool isValid = controllerContent.text.length <= MAX_REVIEW_LENGTH;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4.0,
      children: [
        Row(
          children: [
            Text("Your review", style: TextStyle(color: Colors.grey, fontSize: 20)),
            const Spacer(),
            Text(
              "${controllerContent.text.length}/$MAX_REVIEW_LENGTH",
              style: TextStyle(color: isValid ? Colors.grey : Colors.red, fontSize: 20),
            ),
          ],
        ),
        buildContentField(),
      ],
    );
  }

  Widget buildContentField() {
    return TextFormField(
      controller: controllerContent,
      keyboardType: TextInputType.multiline,
      minLines: 5,
      maxLines: 5,
      decoration: InputDecoration(
        hintText: "Write your review... ",
        border: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
      ),
      style: const TextStyle(color: Colors.white, fontSize: 20),
      onChanged: (_) => setState(() {}),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter some text';
        }
        if (value.length > MAX_REVIEW_LENGTH) {
          return 'Review must be less than $MAX_REVIEW_LENGTH characters';
        }
        return null;
      },
    );
  }

  Widget buildSubmitButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: Size(0.0, 40.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        backgroundColor: PRIMARY_COLOR_DARK,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
      onPressed: () => {},
      child: Text("Post", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
    );
  }
}
