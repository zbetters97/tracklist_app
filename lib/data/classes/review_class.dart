import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tracklist_app/data/classes/media_class.dart';

class Review {
  final String reviewId;
  final String uid;
  final String username;
  final Timestamp createdAt;
  final String category;
  final double rating;
  final String content;
  final List<dynamic> likes;
  final List<dynamic> dislikes;
  final List<dynamic> comments;
  final Media media;
  final DocumentSnapshot doc;

  Review({
    required this.reviewId,
    required this.uid,
    required this.username,
    required this.createdAt,
    required this.category,
    required this.rating,
    required this.content,
    required this.likes,
    required this.dislikes,
    required this.comments,
    required this.media,
    required this.doc,
  });

  factory Review.fromJson(Map<String, dynamic> json, {required Media media, required DocumentSnapshot doc}) {
    return Review(
      reviewId: json['reviewId'],
      uid: json['uid'],
      username: json['username'],
      createdAt: json['createdAt'],
      category: json['category'],
      rating: (json['rating'] as num).toDouble(),
      content: json['content'],
      likes: json['likes'] ?? [],
      dislikes: json['dislikes'] ?? [],
      comments: json['comments'] ?? [],
      media: media,
      doc: doc,
    );
  }

  static int compareByDate(Review a, Review b) {
    return b.createdAt.compareTo(a.createdAt);
  }
}
