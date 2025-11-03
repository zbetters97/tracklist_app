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
import 'package:tracklist_app/features/review/widgets/review_comments_section.dart';
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

  void sendToUserPage(BuildContext context, String userId) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => UserPage(uid: userId)));
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
                  const SizedBox(height: 24.0),
                  buildReviewHeader(user.username, user.profileUrl, review.createdAt, review.rating),
                  const SizedBox(height: 8.0),
                  buildReviewContent(review.content),
                  const SizedBox(height: 12.0),
                  buildReviewButtons(user.uid, review),
                ],
              ),
            ),
            const Divider(color: Colors.white, thickness: 1, height: 0),
            ReviewCommentsSection(review: review),
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
        GestureDetector(onTap: () => sendToUserPage(context, user.uid), child: profileImage),
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
                      recognizer: TapGestureRecognizer()..onTap = () => sendToUserPage(context, user.uid),
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
      padding: const EdgeInsets.all(4.0),
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
    bool isLiked = review.likes.contains(user.uid);

    return GestureDetector(
      onTap: () async {
        setState(() {
          isLiked ? review.likes.remove(userId) : review.likes.add(userId);
        });
        await likeReview(review.reviewId, userId);
      },
      child: Row(
        children: [
          Icon(Icons.favorite, size: 30, color: isLiked ? PRIMARY_COLOR_LIGHT : Colors.white),
          const SizedBox(width: 3),
          Text("$likes", style: TextStyle(color: isLiked ? PRIMARY_COLOR_LIGHT : Colors.white, fontSize: 24)),
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
}
