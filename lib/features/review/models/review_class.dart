import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tracklist_app/core/constants/constants.dart';
import 'package:tracklist_app/core/utils/date.dart';
import 'package:tracklist_app/core/utils/notifiers.dart';
import 'package:tracklist_app/core/widgets/stars_widget.dart';
import 'package:tracklist_app/features/user/models/app_user_class.dart';
import 'package:tracklist_app/features/media/models/media_class.dart';

class Review {
  final String reviewId;
  final DateTime createdAt;
  final String category;
  final double rating;
  final String content;
  int likeCount;
  final List<String> likes;
  final List<String> dislikes;
  final List<String> comments;
  final AppUser user;
  final Media media;
  final DocumentSnapshot doc;

  Review({
    required this.reviewId,
    required this.createdAt,
    required this.category,
    required this.rating,
    required this.content,
    required this.likeCount,
    required this.likes,
    required this.dislikes,
    required this.comments,
    required this.user,
    required this.media,
    required this.doc,
  });

  factory Review.fromJson(
    Map<String, dynamic> json, {
    required AppUser user,
    required Media media,
    required DocumentSnapshot doc,
  }) {
    return Review(
      reviewId: json['reviewId'],
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      category: json['category'],
      rating: (json['rating'] as num).toDouble(),
      content: json['content'],
      likeCount: json['likeCount'],
      likes: List<String>.from(json['likes']),
      dislikes: List<String>.from(json['dislikes']),
      comments: List<String>.from(json['comments']),
      user: user,
      media: media,
      doc: doc,
    );
  }

  static int compareByDate(Review a, Review b) {
    return b.createdAt.compareTo(a.createdAt);
  }

  Widget buildDateShort(double fontSize) {
    return Text(
      getTimeSinceShort(createdAt),
      style: TextStyle(
        color: Colors.grey,
        fontWeight: FontWeight.bold,
        fontSize: fontSize,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget buildDateLong(double fontSize) {
    return Text(
      formatDateMDY(createdAt),
      style: TextStyle(color: Colors.grey, fontSize: fontSize),
    );
  }

  Widget buildContent(double fontSize) {
    return Text(
      content,
      textAlign: TextAlign.left,
      style: TextStyle(color: Colors.white, fontSize: fontSize),
      overflow: TextOverflow.ellipsis,
      maxLines: 4,
    );
  }

  Widget buildStarRating(bool isCentered) {
    return StarRating(rating: rating, isCentered: isCentered);
  }

  Widget buildLikeButton(Function onVoteReview) {
    bool isLiked = likes.contains(authUser.value!.uid);

    return GestureDetector(
      onTap: () => onVoteReview(isLiked),
      child: Row(
        spacing: 5.0,
        children: [
          Icon(Icons.favorite, size: 30, color: isLiked ? PRIMARY_COLOR_LIGHT : Colors.white),
          Text("$likeCount", style: TextStyle(color: isLiked ? PRIMARY_COLOR_LIGHT : Colors.white, fontSize: 24)),
        ],
      ),
    );
  }

  Widget buildLikeButtonDetailed(Function onVoteReview, Function sendToLikesPage) {
    bool isLiked = likes.contains(authUser.value!.uid);
    String likesWord = likeCount == 1 ? "like" : "likes";

    return Row(
      spacing: 5.0,
      children: [
        GestureDetector(
          onTap: () => onVoteReview(isLiked),
          child: Icon(Icons.favorite, size: 30, color: isLiked ? PRIMARY_COLOR_LIGHT : Colors.white),
        ),
        GestureDetector(
          onTap: () => sendToLikesPage(),
          child: Text(
            "$likeCount $likesWord",
            style: TextStyle(color: isLiked ? PRIMARY_COLOR_LIGHT : Colors.white, fontSize: 24),
          ),
        ),
      ],
    );
  }

  Widget buildDeleteButton(Function onDeleteReview) {
    return GestureDetector(onTap: () => onDeleteReview(), child: Icon(Icons.delete, size: 30));
  }
}
