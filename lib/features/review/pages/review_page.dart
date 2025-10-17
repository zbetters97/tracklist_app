import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:tracklist_app/data/models/auth_user_class.dart';
import 'package:tracklist_app/data/models/media_class.dart';
import 'package:tracklist_app/data/models/review_class.dart';
import 'package:tracklist_app/core/constants/constants.dart';
import 'package:tracklist_app/core/utils/date.dart';
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
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              buildMediaBanner(media.image, review.category, media.name),
              const SizedBox(height: 24),
              buildReviewHeader(user.username, user.profileUrl, review.createdAt, review.rating),
              const SizedBox(height: 12),
              buildReviewContent(review.content),
            ],
          ),
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
}
