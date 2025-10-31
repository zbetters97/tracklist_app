import 'package:flutter/material.dart';
import 'package:tracklist_app/data/models/auth_user_class.dart';
import 'package:tracklist_app/data/models/media_class.dart';
import 'package:tracklist_app/data/models/review_class.dart';
import 'package:tracklist_app/core/constants/constants.dart';
import 'package:tracklist_app/core/utils/date.dart';
import 'package:tracklist_app/data/sources/auth_service.dart';
import 'package:tracklist_app/core/widgets/stars_widget.dart';
import 'package:tracklist_app/data/sources/review_service.dart';

class ReviewCardWidget extends StatefulWidget {
  const ReviewCardWidget({super.key, required this.review, required this.onOpenReview});

  final Review review;

  // Callback to open the review page
  final void Function(Review review) onOpenReview;

  @override
  State<ReviewCardWidget> createState() => _ReviewCardWidgetState();
}

class _ReviewCardWidgetState extends State<ReviewCardWidget> {
  Review get review => widget.review;
  Media get media => widget.review.media;
  AuthUser get user => widget.review.user;
  int get likes => widget.review.likes.length;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 10, bottom: 10, left: 5, right: 5),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => widget.onOpenReview(review),
            child: Column(
              children: [
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      buildMediaImage(media.image),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            buildUserInfo(user.username, user.profileUrl),
                            buildReviewDate(review.createdAt),
                            buildMediaName(review.category, media.name),
                            StarRating(rating: review.rating),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                buildReviewContent(review.content),
              ],
            ),
          ),
          const SizedBox(height: 10),
          buildReviewButtons(user.uid, review),
        ],
      ),
    );
  }

  Widget buildMediaImage(String imageUrl) {
    return Image.network(imageUrl, width: 125, height: 125, fit: BoxFit.cover);
  }

  Widget buildUserInfo(String username, String profileUrl) {
    CircleAvatar profileImage = profileUrl.startsWith("https")
        ? CircleAvatar(radius: 12.0, backgroundImage: NetworkImage(profileUrl))
        : CircleAvatar(radius: 12.0, backgroundImage: AssetImage(DEFAULT_PROFILE_IMG));

    return Row(
      children: [
        profileImage,
        const SizedBox(width: 5),
        Text("@$username", style: TextStyle(color: Colors.grey, fontSize: 16)),
      ],
    );
  }

  Widget buildReviewDate(DateTime date) {
    return Text(
      getTimeSinceShort(date),
      style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 16, overflow: TextOverflow.ellipsis),
    );
  }

  Widget buildMediaName(String category, String name) {
    Icon mediaIcon = category == "artist"
        ? Icon(Icons.person, color: Colors.grey, size: 24)
        : category == "album"
        ? Icon(Icons.album, color: Colors.grey, size: 24)
        : Icon(Icons.music_note, color: Colors.grey, size: 24);

    return Row(
      children: [
        mediaIcon,
        Flexible(
          child: Text(
            name,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
      ],
    );
  }

  Widget buildReviewContent(String content) {
    return Text(
      content,
      textAlign: TextAlign.left,
      style: TextStyle(color: Colors.white, fontSize: 20),
      overflow: TextOverflow.ellipsis,
      maxLines: 4,
    );
  }

  Widget buildReviewButtons(String userId, Review review) {
    bool isPoster = userId == authUser.value!.uid;

    return Row(
      children: [
        buildLikeButton(review, userId),
        const SizedBox(width: 20),
        buildCommentButton(review.comments.length),
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

  Widget buildCommentButton(int comments) {
    return Row(
      children: [
        Icon(Icons.comment, size: 30),
        const SizedBox(width: 3),
        Text("$comments", style: TextStyle(color: Colors.white, fontSize: 24)),
      ],
    );
  }

  Widget buildDeleteButton() {
    return Icon(Icons.delete, size: 30);
  }
}
