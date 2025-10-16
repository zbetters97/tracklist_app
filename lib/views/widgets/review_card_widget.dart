import 'package:flutter/material.dart';
import 'package:tracklist_app/data/classes/review_class.dart';
import 'package:tracklist_app/data/constants.dart';
import 'package:tracklist_app/data/utils/date.dart';
import 'package:tracklist_app/services/auth_service.dart';

class ReviewCardWidget extends StatefulWidget {
  const ReviewCardWidget({super.key, required this.review});

  final Review review;

  @override
  State<ReviewCardWidget> createState() => _ReviewCardWidgetState();
}

class _ReviewCardWidgetState extends State<ReviewCardWidget> {
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
                buildMediaImage(widget.review.media.image),
                SizedBox(width: 10),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      buildUserInfo(widget.review.username),
                      buildReviewDate(widget.review.createdAt.toDate()),
                      buildMediaName(widget.review.category, widget.review.media.name),
                      buildReviewStars(widget.review.rating),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          buildReviewContent(widget.review.content),
          SizedBox(height: 10),
          buildReviewButtons(widget.review.uid, widget.review.likes.length, widget.review.comments.length),
        ],
      ),
    );
  }

  Widget buildMediaImage(String imageUrl) {
    return Image.network(imageUrl, width: 125, height: 125, fit: BoxFit.cover);
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

  Widget buildReviewStars(int rating) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(Icons.star, color: index < rating ? Colors.amber : Colors.grey);
      }),
    );
  }

  Widget buildReviewButtons(String userId, int likes, int comments) {
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

  Widget buildLikeButton(int likes) {
    return Row(
      children: [
        Icon(Icons.favorite, size: 30),
        SizedBox(width: 5),
        Text("$likes", style: TextStyle(color: Colors.white, fontSize: 24)),
      ],
    );
  }

  Widget buildCommentButton(int comments) {
    return Row(
      children: [
        Icon(Icons.comment, size: 30),
        SizedBox(width: 5),
        Text("$comments", style: TextStyle(color: Colors.white, fontSize: 24)),
      ],
    );
  }

  Widget buildDeleteButton() {
    return Icon(Icons.delete, size: 30);
  }
}
