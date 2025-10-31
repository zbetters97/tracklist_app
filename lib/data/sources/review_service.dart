import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tracklist_app/data/models/auth_user_class.dart';
import 'package:tracklist_app/data/models/media_class.dart';
import 'package:tracklist_app/data/models/review_class.dart';
import 'package:tracklist_app/core/constants/constants.dart';
import 'package:tracklist_app/data/sources/auth_service.dart';
import 'package:tracklist_app/data/sources/spotify_service.dart';

final FirebaseFirestore firestore = FirebaseFirestore.instance;

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
        .orderBy("likes", descending: true)
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
        AuthUser user = await authService.value.getUserById(userId: userId);

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
    List<String> following = authService.value.getFollowingByUserId();

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
        AuthUser user = await authService.value.getUserById(userId: userId);

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

        AuthUser user = await authService.value.getUserById(userId: userId);

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
