import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tracklist_app/core/utils/notifiers.dart';
import 'package:tracklist_app/features/user/models/app_user_class.dart';
import 'package:tracklist_app/features/comment/services/comment_service.dart';
import 'package:tracklist_app/features/media/models/media_class.dart';
import 'package:tracklist_app/features/review/models/review_class.dart';
import 'package:tracklist_app/core/constants/constants.dart';
import 'package:tracklist_app/features/media/services/spotify_service.dart';
import 'package:tracklist_app/features/user/services/user_service.dart';

final FirebaseFirestore firestore = FirebaseFirestore.instance;

Future<bool> addReview(String category, String content, String mediaId, double rating) async {
  try {
    if (authUser.value == null) throw Exception("User is not logged in");

    Map<String, dynamic> newReviewData = {
      "category": category,
      "comments": [],
      "content": content,
      "createdAt": FieldValue.serverTimestamp(),
      "dislikes": [],
      "likeCount": 0,
      "likes": [],
      "mediaId": mediaId,
      "rating": rating,
      "userId": authUser.value!.uid,
    };

    // Create review document in Firestore
    await firestore.collection("reviews").add(newReviewData);

    return true;
  } catch (error) {
    throw Exception("Error adding review: $error");
  }
}

Future<Review> getReviewById(String reviewId) async {
  try {
    final reviewRef = firestore.collection("reviews").doc(reviewId);
    final reviewDoc = await reviewRef.get();

    if (!reviewDoc.exists) throw Exception("Review does not exist in database");

    final data = reviewDoc.data() as Map<String, dynamic>;

    AppUser user = await getUserById(userId: data["userId"]);
    Media media = await getMediaById(data["mediaId"], data["category"]);

    // Create Review object
    final reviewJson = {...data, "reviewId": reviewDoc.id};
    return Review.fromJson(reviewJson, user: user, media: media, doc: reviewDoc);
  } catch (error) {
    throw Exception("Error getting review by id: $error");
  }
}

Future<List<Review>> getPopularReviews({DocumentSnapshot? lastDoc, int limit = MAX_REVIEWS}) async {
  try {
    // Retrieve Reviews from Firestore
    final reviewsRef = firestore.collection("reviews");

    // Get the date X days ago
    DateTime earliestDate = DateTime.now();
    earliestDate = earliestDate.subtract(Duration(days: EARLIEST_DATE));

    // Get reviews after earliest date, order by likes, then by date
    final reviewsQuery = reviewsRef
        .where("createdAt", isGreaterThanOrEqualTo: earliestDate)
        .orderBy("likeCount", descending: true)
        .orderBy("createdAt", descending: true)
        .limit(limit);

    QuerySnapshot reviewsSnapshot;

    // If lastDoc is not null, start after it
    if (lastDoc != null) {
      reviewsSnapshot = await reviewsQuery.startAfterDocument(lastDoc).get();
    } else {
      reviewsSnapshot = await reviewsQuery.get();
    }

    if (reviewsSnapshot.docs.isEmpty) return [];

    // Map each review to a Review object
    final List<Review> reviews = await Future.wait(
      reviewsSnapshot.docs.map((doc) async {
        // Store data from Firestore
        final data = doc.data() as Map<String, dynamic>;

        String userId = data["userId"];
        AppUser user = await getUserById(userId: userId);

        String mediaId = data["mediaId"];
        String category = data["category"];

        Media media = await getMediaById(mediaId, category);

        // Create Review object
        final reviewJson = {...data, "reviewId": doc.id};
        return Review.fromJson(reviewJson, user: user, media: media, doc: doc);
      }),
    );

    return reviews;
  } catch (error) {
    throw Exception("Error getting popular reviews: $error");
  }
}

Future<List<Review>> getFollowingReviews({DocumentSnapshot? lastDoc, int limit = MAX_REVIEWS}) async {
  try {
    if (authUser.value == null) return [];

    // Get list of users that the current user is following
    List<String> following = getAppUserFollowingUserIds();

    // Include current user's reviews
    following.add(authUser.value!.uid);

    // Retrieve Reviews from Firestore where userId is in following, sort by date
    final reviewsRef = firestore
        .collection("reviews")
        .where("userId", whereIn: following)
        .orderBy("createdAt", descending: true)
        .limit(limit);

    QuerySnapshot reviewsSnapshot;

    // If lastDoc is not null, start after it
    if (lastDoc != null) {
      reviewsSnapshot = await reviewsRef.startAfterDocument(lastDoc).get();
    } else {
      reviewsSnapshot = await reviewsRef.get();
    }

    if (reviewsSnapshot.docs.isEmpty) return [];

    // Map each review to a Review object
    final List<Review> reviews = await Future.wait(
      reviewsSnapshot.docs.map((doc) async {
        // Store data from Firestore
        final data = doc.data() as Map<String, dynamic>;

        String userId = data["userId"];
        AppUser user = await getUserById(userId: userId);

        String mediaId = data["mediaId"];
        String category = data["category"];

        Media media = await getMediaById(mediaId, category);

        final reviewJson = {...data, "reviewId": doc.id};

        // Create Review object
        return Review.fromJson(reviewJson, user: user, media: media, doc: doc);
      }),
    );

    // Sort reviews by date
    reviews.sort((Review.compareByDate));

    return reviews;
  } catch (error) {
    throw Exception("Error getting new reviews: $error");
  }
}

Future<QuerySnapshot> getReviewDocsByMediaId(String mediaId) async {
  // Retrieve Reviews from Firestore
  final reviewsRef = firestore.collection("reviews");

  // Filter by reviews whose mediaId matches
  QuerySnapshot reviewsSnapshot = await reviewsRef.where("mediaId", isEqualTo: mediaId).get();

  return reviewsSnapshot;
}

Future<List<Review>> getReviewsByMediaId(String mediaId) async {
  try {
    // Retrieve Reviews from Firestore
    final reviewsRef = firestore.collection("reviews");

    // Filter by reviews whose mediaId matches
    QuerySnapshot reviewsSnapshot = await reviewsRef.where("mediaId", isEqualTo: mediaId).get();

    if (reviewsSnapshot.docs.isEmpty) return [];

    // Map each review to a Review object
    final List<Review> reviews = await Future.wait(
      reviewsSnapshot.docs.map((doc) async {
        final data = doc.data() as Map<String, dynamic>;

        String userId = data["userId"];

        AppUser user = await getUserById(userId: userId);

        String mediaId = data["mediaId"];
        String category = data["category"];

        Media media = await getMediaById(mediaId, category);

        final reviewJson = {...data, "reviewId": doc.id};
        return Review.fromJson(reviewJson, user: user, media: media, doc: doc);
      }),
    );

    return reviews;
  } catch (error) {
    throw Exception("Error getting reviews by media id: $error");
  }
}

Future<double> getAvgRating(String mediaId) async {
  try {
    // Filter by reviews whose mediaId matches
    QuerySnapshot reviewsSnapshot = await getReviewDocsByMediaId(mediaId);

    if (reviewsSnapshot.docs.isEmpty) return 0.0;

    // Get size of list
    int count = reviewsSnapshot.docs.length;

    double totalRating = 0.0;

    // For each rating, add to total
    for (DocumentSnapshot doc in reviewsSnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      totalRating += data["rating"];
    }

    // Divide total by count to get average
    double avgRating = totalRating / count;

    return avgRating;
  } catch (error) {
    throw Exception("Error getting average rating: $error");
  }
}

Future<int> voteReview(String reviewId) async {
  try {
    if (authUser.value == null) return 0;

    DocumentSnapshot reviewDoc = await firestore.collection("reviews").doc(reviewId).get();

    if (!reviewDoc.exists) return 0;

    List<dynamic> likes = reviewDoc["likes"];

    if (likes.contains(authUser.value!.uid)) {
      // Remove userId from list of likes
      await reviewDoc.reference.update({
        "likeCount": FieldValue.increment(-1),
        "likes": FieldValue.arrayRemove([authUser.value!.uid]),
      });
    } else {
      // Add userId to list of likes
      await reviewDoc.reference.update({
        "likeCount": FieldValue.increment(1),
        "likes": FieldValue.arrayUnion([authUser.value!.uid]),
      });
    }

    await likeContent(reviewId, "review");

    int numLikes = reviewDoc["likeCount"];

    return numLikes;
  } catch (error) {
    throw Exception("Error liking review: $error");
  }
}

Future<List<Review>> getReviewsByUserId(String userId) async {
  try {
    // Retrieve Reviews from Firestore
    final reviewsRef = firestore.collection("reviews");

    // Filter by reviews whose mediaId matches
    QuerySnapshot reviewsSnapshot = await reviewsRef.where("userId", isEqualTo: userId).get();

    if (reviewsSnapshot.docs.isEmpty) return [];

    // Map each review to a Review object
    final List<Review> reviews = await Future.wait(
      reviewsSnapshot.docs.map((doc) async {
        final data = doc.data() as Map<String, dynamic>;

        String userId = data["userId"];

        AppUser user = await getUserById(userId: userId);

        String mediaId = data["mediaId"];
        String category = data["category"];

        Media media = await getMediaById(mediaId, category);

        final reviewJson = {...data, "reviewId": doc.id};
        return Review.fromJson(reviewJson, user: user, media: media, doc: doc);
      }),
    );

    reviews.sort((Review.compareByDate));

    return reviews;
  } catch (error) {
    throw Exception("Error getting reviews by user id: $error");
  }
}

Future<bool> deleteReview(String reviewId) async {
  try {
    // User is not logged in
    if (authUser.value == null) return false;

    final reviewRef = firestore.collection("reviews");
    final reviewDoc = await reviewRef.doc(reviewId).get();

    // Review doesn't exist or user is not the author
    if (!reviewDoc.exists || reviewDoc["userId"] != authUser.value!.uid) return false;

    List<dynamic> comments = reviewDoc["comments"] ?? [];

    // Iterate through comments and delete
    if (comments.isNotEmpty) {
      for (String commentId in comments) {
        await deleteComment(commentId);
      }
    }

    List<dynamic> likes = reviewDoc["likes"] ?? [];

    // Iterate through likes and remove the review from each user's likes from userlikes
    if (likes.isNotEmpty) {
      for (String userId in likes) {
        await unlikeContent(reviewId, "review", userId);
      }
    }

    // Delete review doc
    await reviewRef.doc(reviewId).delete();

    return true;
  } catch (error) {
    throw Exception("Error deleting review: $error");
  }
}

Future<List<AppUser>> getReviewLikeUsers(String reviewId) async {
  try {
    final reviewRef = firestore.collection("reviews");
    final reviewDoc = await reviewRef.doc(reviewId).get();

    if (!reviewDoc.exists) return [];

    List<dynamic> likes = reviewDoc["likes"] ?? [];

    return await Future.wait(
      likes.map((userId) async {
        return await getUserById(userId: userId);
      }),
    );
  } catch (error) {
    throw Exception("Error getting review like users: $error");
  }
}
