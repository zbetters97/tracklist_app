import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tracklist_app/features/auth/models/auth_user_class.dart';
import 'package:tracklist_app/features/comment/models/comment_class.dart';
import 'package:tracklist_app/features/review/models/review_class.dart';
import 'package:tracklist_app/features/auth/services/auth_service.dart';
import 'package:tracklist_app/features/review/services/review_service.dart';

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
    Comment comment = Comment.fromJson({"commentId": commentDoc.id, ...data}, user: user, review: review);
    return comment;
  } catch (error) {
    throw Exception("Error getting comment by id: $error");
  }
}

Future<List<Comment>> getCommentsByReviewId(Review review) async {
  try {
    List<Comment> comments = [];

    for (String commentId in review.comments) {
      Comment comment = await getCommentById(commentId);
      comments.add(comment);
    }

    // Only show top-level comments
    List<Comment> filteredComments = comments.where((comment) => comment.replyingTo == "").toList();

    return filteredComments;
  } catch (error) {
    throw Exception("Error getting comments by review id: $error");
  }
}

Future<List<Comment>> getRepliesByComment(Comment comment) async {
  try {
    List<Comment> replies = [];

    for (String replyId in comment.replies) {
      Comment reply = await getCommentById(replyId);
      replies.add(reply);
    }

    // Only show top-level comments
    //   List<Comment> filteredComments = comments.where((comment) => comment.replyingTo == "").toList();

    return replies;
  } catch (error) {
    throw Exception("Error getting comments by review id: $error");
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

    // Add comment ID to replyingTo doc
    if (replyingToId != "") {
      await firestore.collection("comments").doc(replyingToId).update({
        "replies": FieldValue.arrayUnion([newComment.commentId]),
      });
    }

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
