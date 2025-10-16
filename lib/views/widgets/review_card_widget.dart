import 'package:flutter/material.dart';
import 'package:tracklist_app/data/classes/auth_user_class.dart';
import 'package:tracklist_app/data/classes/media_class.dart';
import 'package:tracklist_app/data/classes/review_class.dart';
import 'package:tracklist_app/data/constants.dart';
import 'package:tracklist_app/data/utils/date.dart';
import 'package:tracklist_app/services/auth_service.dart';
import 'package:tracklist_app/views/widgets/stars_widget.dart';

class ReviewCardWidget extends StatefulWidget {
  const ReviewCardWidget({super.key, required this.review});

  final Review review;

  @override
  State<ReviewCardWidget> createState() => _ReviewCardWidgetState();
}

class _ReviewCardWidgetState extends State<ReviewCardWidget> {
  Review get review => widget.review;
  Media get media => widget.review.media;
  AuthUser get user => widget.review.user;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 10, bottom: 10, left: 5, right: 5),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                buildMediaImage(media.image),
                SizedBox(width: 10),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      buildUserInfo(user.username),
                      buildReviewDate(review.createdAt.toDate()),
                      buildMediaName(review.category, media.name),
                      buildStarRating(review.rating),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          buildReviewContent(review.content),
          SizedBox(height: 10),
          buildReviewButtons(user.uid, review.likes, review.comments.length),
        ],
      ),
    );
  }

  Widget buildMediaImage(String imageUrl) {
    Image profileImage = imageUrl.startsWith("https")
        ? Image.network(imageUrl, width: 125, height: 125, fit: BoxFit.cover)
        : Image.asset(DEFAULT_PROFILE_IMG, width: 125, height: 125, fit: BoxFit.cover);

    return profileImage;
  }

  Widget buildUserInfo(String username) {
    return Row(
      children: [
        CircleAvatar(radius: 12.0, backgroundImage: AssetImage(DEFAULT_PROFILE_IMG)),
        SizedBox(width: 5),
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

  Widget buildReviewButtons(String userId, List<String> likes, int comments) {
    bool isPoster = userId == authUser.value!.uid;

    return Row(
      children: [
        buildLikeButton(likes),
        SizedBox(width: 20),
        buildCommentButton(comments),
        SizedBox(width: 20),
        if (isPoster) buildDeleteButton(),
      ],
    );
  }

  Widget buildLikeButton(List<String> likes) {
    bool isLiked = likes.contains(authUser.value!.uid);

    return Row(
      children: [
        Icon(Icons.favorite, size: 30, color: isLiked ? PRIMARY_COLOR : Colors.white),
        SizedBox(width: 3),
        Text("${likes.length}", style: TextStyle(color: isLiked ? PRIMARY_COLOR : Colors.white, fontSize: 24)),
      ],
    );
  }

  Widget buildCommentButton(int comments) {
    return Row(
      children: [
        Icon(Icons.comment, size: 30),
        SizedBox(width: 3),
        Text("$comments", style: TextStyle(color: Colors.white, fontSize: 24)),
      ],
    );
  }

  Widget buildDeleteButton() {
    return Icon(Icons.delete, size: 30);
  }
}
