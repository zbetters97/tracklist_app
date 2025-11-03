import 'package:flutter/material.dart';
import 'package:tracklist_app/features/auth/models/auth_user_class.dart';
import 'package:tracklist_app/features/review/models/review_class.dart';
import 'package:tracklist_app/core/constants/constants.dart';
import 'package:tracklist_app/core/utils/date.dart';
import 'package:tracklist_app/core/widgets/stars_widget.dart';

class MediaReviewWidget extends StatelessWidget {
  const MediaReviewWidget({super.key, required this.review});

  final Review review;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            buildUserAvatar(review.user.profileUrl),
            const SizedBox(width: 8.0),
            buildReviewHeader(review, review.user),
          ],
        ),
        const SizedBox(height: 4.0),
        buildReviewContent(review.content),
      ],
    );
  }

  Widget buildUserAvatar(String profileUrl) {
    return profileUrl.startsWith("https")
        ? CircleAvatar(radius: 24.0, backgroundImage: NetworkImage(profileUrl))
        : CircleAvatar(radius: 24.0, backgroundImage: AssetImage(DEFAULT_PROFILE_IMG));
  }

  Widget buildReviewHeader(Review review, AuthUser user) {
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
        style: TextStyle(color: Colors.white, fontSize: 18),
        overflow: TextOverflow.ellipsis,
        maxLines: 4,
      ),
    );
  }
}
