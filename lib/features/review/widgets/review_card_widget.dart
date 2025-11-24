import 'package:flutter/material.dart';
import 'package:tracklist_app/core/utils/notifiers.dart';
import 'package:tracklist_app/features/user/models/app_user_class.dart';
import 'package:tracklist_app/features/media/models/media_class.dart';
import 'package:tracklist_app/features/review/models/review_class.dart';
import 'package:tracklist_app/features/review/services/review_service.dart';

class ReviewCardWidget extends StatefulWidget {
  final Review review;
  final VoidCallback onOpenReview;
  final VoidCallback onDeleteReview;

  const ReviewCardWidget({super.key, required this.review, required this.onOpenReview, required this.onDeleteReview});

  @override
  State<ReviewCardWidget> createState() => _ReviewCardWidgetState();
}

class _ReviewCardWidgetState extends State<ReviewCardWidget> {
  Review get review => widget.review;
  Media get media => widget.review.media;
  AppUser get user => widget.review.user;
  int get likes => widget.review.likeCount;

  void _onVoteReview(bool isLiked) async {
    setState(() {
      if (isLiked) {
        review.likes.remove(authUser.value!.uid);
        review.likeCount--;
      } else {
        review.likes.add(authUser.value!.uid);
        review.likeCount++;
      }
    });

    await voteReview(review.reviewId);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 10, bottom: 10, left: 5, right: 5),
      width: double.infinity,
      child: Column(
        spacing: 10.0,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => widget.onOpenReview(),
            child: Column(
              spacing: 10.0,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IntrinsicHeight(
                  child: Row(
                    spacing: 10.0,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [review.media.buildImage(125), _buildReviewInfo()],
                  ),
                ),
                review.buildContent(20.0),
              ],
            ),
          ),
          _buildReviewButtons(),
        ],
      ),
    );
  }

  Widget _buildReviewInfo() {
    return Flexible(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          user.buildProfileAndUsername(context, 16.0, 12.0),
          review.buildDateShort(16.0),
          review.media.buildName(review.category, false),
          review.buildStarRating(false),
        ],
      ),
    );
  }

  Widget _buildReviewButtons() {
    bool isAuthor = review.user.uid == authUser.value!.uid;

    return Row(
      spacing: 20.0,
      children: [
        review.buildLikeButton(_onVoteReview),
        _buildCommentButton(),
        if (isAuthor) review.buildDeleteButton(widget.onDeleteReview),
      ],
    );
  }

  Widget _buildCommentButton() {
    return GestureDetector(
      onTap: () => widget.onOpenReview(),
      child: Row(
        spacing: 5.0,
        children: [
          Icon(Icons.comment, size: 30),
          Text("${review.comments.length}", style: TextStyle(color: Colors.white, fontSize: 24)),
        ],
      ),
    );
  }
}
