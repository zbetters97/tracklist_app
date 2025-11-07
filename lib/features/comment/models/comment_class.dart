import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tracklist_app/features/user/models/app_user_class.dart';
import 'package:tracklist_app/features/review/models/review_class.dart';

class Comment {
  final String commentId;
  final DateTime createdAt;
  final String content;
  final AppUser user;
  final Review review;
  final List<String> likes;
  final List<String> dislikes;
  final List<String> replies;
  final String replyingTo;

  Comment({
    required this.commentId,
    required this.createdAt,
    required this.content,
    required this.user,
    required this.review,
    required this.likes,
    required this.dislikes,
    required this.replies,
    required this.replyingTo,
  });

  factory Comment.fromJson(Map<String, dynamic> json, {required AppUser user, required Review review}) {
    return Comment(
      commentId: json['commentId'],
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      content: json['content'],
      user: user,
      review: review,
      likes: List<String>.from(json['likes']),
      dislikes: List<String>.from(json['dislikes']),
      replies: List<String>.from(json['replies']),
      replyingTo: json['replyingTo'],
    );
  }

  // Sort comments by newest to oldest
  static int compareByNewest(Comment a, Comment b) {
    return b.createdAt.compareTo(a.createdAt);
  }

  // Sort comments by oldest to newest
  static int compareByOldest(Comment a, Comment b) {
    return a.createdAt.compareTo(b.createdAt);
  }

  // Sort comments by number of likes, highest to lowest
  static int compareByLikes(Comment a, Comment b) {
    final likeComparison = b.likes.length.compareTo(a.likes.length);
    if (likeComparison != 0) return likeComparison;

    // If likes are same, sort by dislikes, lowest to highest
    return a.dislikes.length.compareTo(b.dislikes.length);
  }

  // Sort comments by number of dislikes, highest to lowest
  static int compareByDislikes(Comment a, Comment b) {
    final dislikeComparison = b.dislikes.length.compareTo(a.dislikes.length);
    if (dislikeComparison != 0) return dislikeComparison;

    // If dislikes are same, sort by likes, lowest to highest
    return a.likes.length.compareTo(b.likes.length);
  }
}
