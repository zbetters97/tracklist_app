import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:tracklist_app/data/models/auth_user_class.dart';
import 'package:tracklist_app/data/models/media_class.dart';
import 'package:tracklist_app/data/models/review_class.dart';
import 'package:tracklist_app/core/constants/constants.dart';
import 'package:tracklist_app/core/utils/date.dart';
import 'package:tracklist_app/data/sources/auth_service.dart';
import 'package:tracklist_app/data/sources/review_service.dart';
import 'package:tracklist_app/features/media/pages/media_page.dart';
import 'package:tracklist_app/features/user/pages/user_page.dart';
import 'package:tracklist_app/core/widgets/my_app_bar.dart';
import 'package:tracklist_app/core/widgets/stars_widget.dart';

class ReviewPage extends StatefulWidget {
  const ReviewPage({super.key, required this.review});

  final Review review;

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  Review get review => widget.review;
  Media get media => widget.review.media;
  AuthUser get user => widget.review.user;
  int get likes => review.likes.length;

  TextEditingController commentController = TextEditingController();

  final List<String> commentFilters = ["Newest", "Oldest", "Best", "Worst"];
  int selectedFilter = 0;

  void sendToMediaPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return MediaPage(media: media);
        },
      ),
    );
  }

  void sendToUserPage(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => UserPage(uid: user.uid)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: "Review"),
      backgroundColor: BACKGROUND_COLOR,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  buildMediaBanner(media.image, review.category, media.name),
                  const SizedBox(height: 24),
                  buildReviewHeader(user.username, user.profileUrl, review.createdAt, review.rating),
                  const SizedBox(height: 12),
                  buildReviewContent(review.content),
                  const SizedBox(height: 12),
                  buildReviewButtons(user.uid, review),
                ],
              ),
            ),
            const Divider(color: Colors.white, thickness: 1, height: 0),
            buildCommentsSection(review),
          ],
        ),
      ),
    );
  }

  Widget buildMediaBanner(String imageUrl, String category, String name) {
    Icon mediaIcon = category == "artist"
        ? Icon(Icons.person, color: Colors.grey, size: 28)
        : category == "album"
        ? Icon(Icons.album, color: Colors.grey, size: 28)
        : Icon(Icons.music_note, color: Colors.grey, size: 28);

    return GestureDetector(
      onTap: () => sendToMediaPage(context),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              boxShadow: [BoxShadow(color: Colors.black.withAlpha(75), blurRadius: 12, offset: Offset(0, 4))],
            ),
            child: Image.network(imageUrl, width: 275, height: 275, fit: BoxFit.cover),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              mediaIcon,
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  name,
                  style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildReviewHeader(String username, String profileUrl, DateTime date, double rating) {
    CircleAvatar profileImage = profileUrl.startsWith("https")
        ? CircleAvatar(radius: 30.0, backgroundImage: NetworkImage(profileUrl))
        : CircleAvatar(radius: 30.0, backgroundImage: AssetImage(DEFAULT_PROFILE_IMG));

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(onTap: () => sendToUserPage(context), child: profileImage),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  style: TextStyle(color: Colors.grey, fontSize: 18),
                  children: [
                    TextSpan(text: "Review by "),
                    TextSpan(
                      text: username,
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      recognizer: TapGestureRecognizer()..onTap = () => sendToUserPage(context),
                    ),
                  ],
                ),
              ),
              Text(formatDateMDY(date), style: TextStyle(color: Colors.grey, fontSize: 18)),
              StarRating(rating: rating),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildReviewContent(String content) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(content, style: TextStyle(color: Colors.white, fontSize: 20)),
    );
  }

  Widget buildReviewButtons(String userId, Review review) {
    bool isPoster = userId == authUser.value!.uid;

    return Row(
      children: [
        buildLikeButton(review, userId),
        const SizedBox(width: 20),
        buildShareButton(),
        const SizedBox(width: 20),
        if (isPoster) buildDeleteButton(),
      ],
    );
  }

  Widget buildLikeButton(Review review, String userId) {
    bool isLiked = widget.review.likes.contains(user.uid);

    return GestureDetector(
      onTap: () async {
        setState(() {
          isLiked ? review.likes.remove(userId) : review.likes.add(userId);
        });
        await likeReview(review.reviewId, userId);
      },
      child: Row(
        children: [
          Icon(Icons.favorite, size: 30, color: isLiked ? PRIMARY_COLOR : Colors.white),
          const SizedBox(width: 3),
          Text("$likes", style: TextStyle(color: isLiked ? PRIMARY_COLOR : Colors.white, fontSize: 24)),
        ],
      ),
    );
  }

  Widget buildShareButton() {
    return Icon(Icons.send, size: 30);
  }

  Widget buildDeleteButton() {
    return Icon(Icons.delete, size: 30);
  }

  Widget buildCommentsSection(Review review) {
    String profileUrl = authUser.value?.profileUrl ?? "";
    CircleAvatar profileImage = profileUrl.startsWith("https")
        ? CircleAvatar(radius: 20.0, backgroundImage: NetworkImage(profileUrl))
        : CircleAvatar(radius: 20.0, backgroundImage: AssetImage(DEFAULT_PROFILE_IMG));

    return Container(
      decoration: BoxDecoration(color: TERTIARY_COLOR),
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${review.comments.length} Comments",
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            ToggleButtons(
              isSelected: List.generate(commentFilters.length, (index) => index == selectedFilter),
              onPressed: (index) => setState(() => selectedFilter = index),
              color: Colors.white,
              selectedColor: Colors.black,
              selectedBorderColor: Colors.white,
              fillColor: Colors.white,
              borderColor: Colors.grey,
              constraints: BoxConstraints(minHeight: 40),
              borderRadius: BorderRadius.circular(8),
              children: commentFilters.map((label) {
                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                );
              }).toList(),
            ),
            const SizedBox(height: 24.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 8.0,
              children: [
                profileImage,
                Expanded(
                  child: TextField(
                    style: TextStyle(fontSize: 20),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(0.0, 40.0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    backgroundColor: PRIMARY_COLOR_DARK,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
                  ),
                  onPressed: () {},
                  child: Text("Post", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                ),
              ],
            ),
            Text("Comments List"),
          ],
        ),
      ),
    );
  }
}
