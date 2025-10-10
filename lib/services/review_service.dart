import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tracklist_app/data/constants.dart';
import 'package:tracklist_app/services/auth_service.dart';
import 'package:tracklist_app/services/spotify_service.dart';

final FirebaseFirestore firestore = FirebaseFirestore.instance;

Future<List<Map<String, dynamic>>> getNewReviews({DocumentSnapshot? lastDoc, int limit = MAX_REVIEWS}) async {
  try {
    final reviewsRef = firestore.collection("reviews").orderBy("createdAt", descending: true).limit(limit);

    QuerySnapshot reviewsSnapshot;

    if (lastDoc != null) {
      reviewsSnapshot = await reviewsRef.startAfterDocument(lastDoc).get();
    } else {
      reviewsSnapshot = await reviewsRef.get();
    }

    if (reviewsSnapshot.docs.isEmpty) return [];

    final reviews = await Future.wait(
      reviewsSnapshot.docs.map((doc) async {
        final data = doc.data() as Map<String, dynamic>;

        String userId = data["userId"];
        String username = await authService.value.getUserById(userId: userId);

        String mediaId = data["mediaId"];
        String category = data["category"];

        Map<String, dynamic> media = await getMediaById(mediaId, category);

        return {"id": doc.id, ...data, "username": username, ...media, "doc": doc};
      }),
    );

    reviews.sort((a, b) {
      final aDate = (a['createdAt'] as Timestamp).toDate();
      final bDate = (b['createdAt'] as Timestamp).toDate();

      return bDate.compareTo(aDate);
    });

    return reviews;
  } catch (error) {
    print("Error getting popular reviews: $error");
    return [];
  }
}

Future<List<Map<String, dynamic>>> getPopularReviews({DocumentSnapshot? lastDoc, int limit = MAX_REVIEWS}) async {
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

    final List<Map<String, dynamic>> reviews = await Future.wait(
      reviewsSnapshot.docs.map((doc) async {
        final data = doc.data() as Map<String, dynamic>;

        String userId = data["userId"];
        String username = await authService.value.getUserById(userId: userId);

        String mediaId = data["mediaId"];
        String category = data["category"];

        Map<String, dynamic> media = await getMediaById(mediaId, category);

        return {"id": doc.id, ...data, "username": username, ...media, "doc": doc};
      }),
    );

    return reviews;
  } catch (error) {
    print("Error getting popular reviews: $error");
    return [];
  }
}
