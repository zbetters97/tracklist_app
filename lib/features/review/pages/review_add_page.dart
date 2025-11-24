import 'package:flutter/material.dart';
import 'package:tracklist_app/core/constants/constants.dart';
import 'package:tracklist_app/core/widgets/default_app_bar.dart';
import 'package:tracklist_app/features/media/models/album_class.dart';
import 'package:tracklist_app/features/media/models/media_class.dart';
import 'package:tracklist_app/features/media/models/track_class.dart';
import 'package:tracklist_app/features/media/services/spotify_service.dart';
import 'package:tracklist_app/features/review/services/review_service.dart';

class ReviewAddPage extends StatefulWidget {
  final Media? media;
  const ReviewAddPage({super.key, this.media});

  @override
  State<ReviewAddPage> createState() => _ReviewAddPageState();
}

class _ReviewAddPageState extends State<ReviewAddPage> {
  final _formKey = GlobalKey<FormState>();

  late Media? media = widget.media;
  List<Media> _suggestions = [];
  String _selectedCategory = "artist";
  final TextEditingController _controllerName = TextEditingController();
  final TextEditingController _controllerContent = TextEditingController();
  double _rating = 0.0;

  @override
  void initState() {
    super.initState();

    if (media != null) {
      _controllerName.text = media!.name;
      _selectedCategory = media!.getCategory();
    }
  }

  @override
  void dispose() {
    _controllerName.dispose();
    _controllerContent.dispose();
    super.dispose();
  }

  void _onSearchPressed() async {
    List<Media> fetchedMedia = await searchByCategory(_selectedCategory, _controllerName.text, limit: 5);

    if (_controllerName.text.isEmpty) {
      setState(() => _suggestions = []);
      return;
    }

    setState(() => _suggestions = fetchedMedia);
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate() || media == null || _rating < 0.5) return;

    String category = media!.getCategory();
    bool success = await addReview(category, _controllerContent.text, media!.id, _rating);

    if (success) {
      _sendToHome();
    }
  }

  void _sendToHome() {
    Navigator.pop(context);
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
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 16.0,
                  children: [
                    _buildMediaImage(),
                    _buildSearchName(),
                    _buildRating(),
                    _buildContent(),
                    _buildSubmitButton(),
                  ],
                ),
              ),
              _buildMediaList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMediaImage() {
    if (media != null) return media!.buildImage(200);
    return Image.asset(DEFAULT_MEDIA_IMG, width: 200, height: 200, fit: BoxFit.cover);
  }

  Widget _buildSearchName() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(flex: 2, child: _buildNameField()),
        _buildCategoryDropdown(),
      ],
    );
  }

  Widget _buildNameField() {
    String word = _selectedCategory == "track" ? "a" : "an";

    return TextFormField(
      controller: _controllerName,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        border: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        hintText: "Search for $word $_selectedCategory...",
      ),
      onChanged: (value) => _onSearchPressed(),
      style: const TextStyle(color: Colors.white, fontSize: 20),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter some text';
        }
        return null;
      },
    );
  }

  Widget _buildCategoryDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      child: DropdownButton(
        isExpanded: false,
        items: [
          DropdownMenuItem(value: "artist", child: Text("Artist")),
          DropdownMenuItem(value: "album", child: Text("Album")),
          DropdownMenuItem(value: "track", child: Text("Track")),
        ],
        underline: SizedBox(),
        style: TextStyle(fontSize: 20),
        value: _selectedCategory,
        onTap: () => setState(() => _suggestions = []),
        onChanged: (value) => setState(() => _selectedCategory = value!),
      ),
    );
  }

  Widget _buildMediaList() {
    if (_suggestions.isEmpty) {
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
            itemCount: _suggestions.length,
            itemBuilder: (context, index) {
              final item = _suggestions[index];
              return InkWell(
                onTap: () {
                  setState(() {
                    media = item;
                    _controllerName.text = item.name;
                    _suggestions = [];
                  });
                },
                child: _buildMediaItem(item),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMediaItem(Media media) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          media.name,
          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        if (_selectedCategory == "album")
          Text((media as Album).artist, style: const TextStyle(color: Colors.white, fontSize: 16)),
        if (_selectedCategory == "track")
          Text((media as Track).artist, style: const TextStyle(color: Colors.white, fontSize: 16)),
      ],
    );
  }

  Widget _buildRating() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4.0,
      children: [
        Text("Your _rating", style: TextStyle(color: Colors.grey, fontSize: 20)),
        _buildStars(),
      ],
    );
  }

  Widget _buildStars() {
    double roundedRating = (_rating * 2).round() / 2;

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(5, (i) {
        double _ratingValue = i + 1;

        bool isHalf = roundedRating == _ratingValue - 0.5;

        Color starColor = _ratingValue - 0.5 <= roundedRating ? Colors.amber : Colors.grey;
        IconData starIcon = isHalf ? Icons.star_half : Icons.star;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (details) {
            setState(() => details.localPosition.dx < 20 ? _rating = _ratingValue - 0.5 : _rating = _ratingValue);
          },
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            child: Icon(starIcon, color: starColor, size: 40),
          ),
        );
      }),
    );
  }

  Widget _buildContent() {
    bool isValid = _controllerContent.text.length <= MAX_REVIEW_LENGTH;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4.0,
      children: [
        Row(
          children: [
            Text("Your review", style: TextStyle(color: Colors.grey, fontSize: 20)),
            const Spacer(),
            Text(
              "${_controllerContent.text.length}/$MAX_REVIEW_LENGTH",
              style: TextStyle(color: isValid ? Colors.grey : Colors.red, fontSize: 20),
            ),
          ],
        ),
        _buildContentField(),
      ],
    );
  }

  Widget _buildContentField() {
    return TextFormField(
      controller: _controllerContent,
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
          return 'Please write a review';
        }
        if (value.length > MAX_REVIEW_LENGTH) {
          return 'Review must be less than $MAX_REVIEW_LENGTH characters';
        }
        return null;
      },
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: Size(0.0, 40.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        backgroundColor: PRIMARY_COLOR_DARK,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
      onPressed: () => _submitForm(),
      child: Text("Post", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
    );
  }
}
