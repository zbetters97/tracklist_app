import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tracklist_app/data/classes/auth_user_class.dart';
import 'package:tracklist_app/data/classes/media_class.dart';
import 'package:tracklist_app/data/classes/review_class.dart';
import 'package:tracklist_app/data/constants.dart';
import 'package:tracklist_app/services/auth_service.dart';
import 'package:tracklist_app/services/spotify_service.dart';

final FirebaseFirestore firestore = FirebaseFirestore.instance;

Future<List<Review>> getNewReviews({DocumentSnapshot? lastDoc, int limit = MAX_REVIEWS}) async {
  try {
    final reviewsRef = firestore.collection("reviews").orderBy("createdAt", descending: true).limit(limit);

    QuerySnapshot reviewsSnapshot;

    if (lastDoc != null) {
      reviewsSnapshot = await reviewsRef.startAfterDocument(lastDoc).get();
    } else {
      reviewsSnapshot = await reviewsRef.get();
    }

    if (reviewsSnapshot.docs.isEmpty) return [];

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

    reviews.sort((Review.compareByDate));

    return reviews;
  } catch (error) {
    throw Exception("Error getting new reviews: $error");
  }
}

Future<List<Review>> getPopularReviews({DocumentSnapshot? lastDoc, int limit = MAX_REVIEWS}) async {
  try {
    final reviewsRef = firestore.collection("reviews");

    DateTime earliestDate = DateTime.now();
    earliestDate = earliestDate.subtract(Duration(days: EARLIEST_DATE));

    final reviewsQuery = reviewsRef
        .where("createdAt", isGreaterThanOrEqualTo: earliestDate)
        .orderBy("likes", descending: true)
        .orderBy("createdAt", descending: true)
        .limit(limit);

    QuerySnapshot reviewsSnapshot;

    if (lastDoc != null) {
      reviewsSnapshot = await reviewsQuery.startAfterDocument(lastDoc).get();
    } else {
      reviewsSnapshot = await reviewsQuery.get();
    }

    if (reviewsSnapshot.docs.isEmpty) return [];

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
    throw Exception("Error getting popular reviews: $error");
  }
}
