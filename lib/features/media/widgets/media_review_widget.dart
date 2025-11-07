import 'package:flutter/material.dart';
import 'package:tracklist_app/features/auth/models/app_user_class.dart';
import 'package:tracklist_app/features/review/models/review_class.dart';
import 'package:tracklist_app/core/constants/constants.dart';
import 'package:tracklist_app/core/utils/date.dart';
import 'package:tracklist_app/core/widgets/stars_widget.dart';

class MediaReviewWidget extends StatelessWidget {
  final Review review;

  const MediaReviewWidget({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4.0,
      children: [
        Row(spacing: 8.0, children: [buildUserAvatar(review.user.profileUrl), buildReviewHeader(review, review.user)]),
        buildReviewContent(review.content),
      ],
    );
  }

  Widget buildUserAvatar(String profileUrl) {
    return profileUrl.startsWith("https")
        ? CircleAvatar(radius: 24.0, backgroundImage: NetworkImage(profileUrl))
        : CircleAvatar(radius: 24.0, backgroundImage: AssetImage(DEFAULT_PROFILE_IMG));
  }

  Widget buildReviewHeader(Review review, AppUser user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            style: TextStyle(color: Colors.grey, fontSize: 16),
            children: [
              TextSpan(text: "Review by "),
              TextSpan(
                text: user.username,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Text(
          getTimeSinceShort(review.createdAt),
          style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        StarRating(rating: review.rating),
      ],
    );
  }

  Widget buildReviewContent(String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Text(
        content,
        textAlign: TextAlign.left,
        style: TextStyle(color: Colors.white, fontSize: 18),
        overflow: TextOverflow.ellipsis,
        maxLines: 4,
      ),
    );
  }
}
