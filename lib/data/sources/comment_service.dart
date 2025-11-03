import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tracklist_app/data/models/auth_user_class.dart';
import 'package:tracklist_app/data/models/comment_class.dart';
import 'package:tracklist_app/data/models/review_class.dart';
import 'package:tracklist_app/data/sources/auth_service.dart';
import 'package:tracklist_app/data/sources/review_service.dart';

final FirebaseFirestore firestore = FirebaseFirestore.instance;

Future<Comment> getCommentById(String commentId) async {
  try {
    // Fetch Comment doc from Firestore by ID
    final commentRef = firestore.collection("comments").doc(commentId);
    final commentDoc = await commentRef.get();

    if (!commentDoc.exists) throw Exception("Comment does not exist in database");

    // Get Comment json data
    final data = commentDoc.data() as Map<String, dynamic>;

    // Get Review and User objects
    Review review = await getReviewById(data["reviewId"]);
    AuthUser user = await authService.value.getUserById(userId: data["userId"]);

    // Create Comment object
    Comment myComment = Comment.fromJson({"commentId": commentDoc.id, ...data}, user: user, review: review);
    return myComment;
  } catch (error) {
    throw Exception("Error getting comment by id: $error");
  }
}

Future<Comment> addComment(String content, String userId, String reviewId, {String replyingToId = ""}) async {
  try {
    final reviewRef = firestore.collection("reviews").doc(reviewId);
    final reviewDoc = await reviewRef.get();

    if (!reviewDoc.exists) throw Exception("Review does not exist in database");

    // Gather comment data
    Map<String, dynamic> newCommentData = {
      "content": content,
      "createdAt": FieldValue.serverTimestamp(),
      "reviewId": reviewId,
      "userId": userId,
      "likes": [],
      "dislikes": [],
      "replyingTo": replyingToId,
      "replies": [],
    };

    // Create comment document in Firestore, grab generated ID
    Comment newComment = await firestore
        .collection("comments")
        .add(newCommentData)
        .then((docRef) => getCommentById(docRef.id));

    // Add comment ID to review doc
    await reviewRef.update({
      "comments": FieldValue.arrayUnion([newComment.commentId]),
    });

    return newComment;
  } catch (error) {
    throw Exception("Error adding comment: $error");
  }
}

Future<void> deleteComment(String commentId) async {
  try {
    // Fetch Comment doc from Firestore by ID
    final commentRef = firestore.collection("comments").doc(commentId);
    final commentDoc = await commentRef.get();

    if (!commentDoc.exists) throw Exception("Comment does not exist in database");

    // Delete comment doc
    await commentRef.delete();

    // Remove comment ID from review doc
    final reviewRef = firestore.collection("reviews").doc(commentDoc["reviewId"]);
    await reviewRef.update({
      "comments": FieldValue.arrayRemove([commentId]),
    });
  } catch (error) {
    throw Exception("Error deleting comment: $error");
  }
}

Future<void> likeComment(String commentId, String userId) async {
  try {
    // Fetch Comment doc from Firestore by ID
    final commentRef = firestore.collection("comments").doc(commentId);
    final commentDoc = await commentRef.get();

    if (!commentDoc.exists) throw Exception("Comment does not exist in database");

    List<dynamic> likes = commentDoc["likes"];
    List<dynamic> dislikes = commentDoc["dislikes"];

    if (likes.contains(userId)) {
      // Remove userId from list of likes
      await commentDoc.reference.update({
        "likes": FieldValue.arrayRemove([userId]),
      });
    } else {
      // Add userId to list of likes
      await commentDoc.reference.update({
        "likes": FieldValue.arrayUnion([userId]),
      });
    }

    if (dislikes.contains(userId)) {
      // Remove userId from list of dislikes
      await commentDoc.reference.update({
        "dislikes": FieldValue.arrayRemove([userId]),
      });
    }
  } catch (error) {
    throw Exception("Error voting comment: $error");
  }
}

Future<void> dislikeComment(String commentId, String userId) async {
  try {
    // Fetch Comment doc from Firestore by ID
    final commentRef = firestore.collection("comments").doc(commentId);
    final commentDoc = await commentRef.get();

    if (!commentDoc.exists) throw Exception("Comment does not exist in database");

    List<dynamic> dislikes = commentDoc["dislikes"];
    List<dynamic> likes = commentDoc["likes"];

    if (dislikes.contains(userId)) {
      // Remove userId from list of dislikes
      await commentDoc.reference.update({
        "dislikes": FieldValue.arrayRemove([userId]),
      });
    } else {
      // Add userId to list of dislikes
      await commentDoc.reference.update({
        "dislikes": FieldValue.arrayUnion([userId]),
      });
    }

    if (likes.contains(userId)) {
      // Remove userId from list of likes
      await commentDoc.reference.update({
        "likes": FieldValue.arrayRemove([userId]),
      });
    }
  } catch (error) {
    throw Exception("Error voting comment: $error");
  }
}
