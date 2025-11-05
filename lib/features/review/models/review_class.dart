import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tracklist_app/features/auth/models/app_user_class.dart';
import 'package:tracklist_app/features/media/models/media_class.dart';

class Review {
  final String reviewId;
  final DateTime createdAt;
  final String category;
  final double rating;
  final String content;
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
}
