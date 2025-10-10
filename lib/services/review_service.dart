import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tracklist_app/data/constants.dart';
import 'package:tracklist_app/services/auth_service.dart';
import 'package:tracklist_app/services/spotify_service.dart';

final FirebaseFirestore firestore = FirebaseFirestore.instance;

Future<List<Map<String, dynamic>>> getNewReviews() async {
  try {
    final reviewsRef = firestore.collection("reviews");
    final reviewsSnapshot = await reviewsRef.get();

    if (reviewsSnapshot.docs.isEmpty) return [];

    final reviews = await Future.wait(
      reviewsSnapshot.docs.map((doc) async {
        final data = doc.data();

        String userId = data["userId"];
        String username = await authService.value.getUserById(userId: userId);

        String mediaId = data["mediaId"];
        String category = data["category"];

        Map<String, dynamic> media = await getMediaById(mediaId, category);

        return {"id": doc.id, ...data, "username": username, ...media};
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

Future<List<Map<String, dynamic>>> getPopularReviews() async {
  try {
    final reviewsRef = firestore.collection("reviews");

    DateTime earliestDate = DateTime.now();
    earliestDate = earliestDate.subtract(Duration(days: EARLIEST_DATE));

    final reviewsQuery = reviewsRef
        .where("createdAt", isGreaterThanOrEqualTo: earliestDate)
        .orderBy("likes", descending: true)
        .orderBy("createdAt", descending: true)
        .limit(20);

    final reviewsSnapshot = await reviewsQuery.get();

    if (reviewsSnapshot.docs.isEmpty) return [];

    final List<Map<String, dynamic>> reviews = await Future.wait(
      reviewsSnapshot.docs.map((doc) async {
        final data = doc.data();

        String userId = data["userId"];
        String username = await authService.value.getUserById(userId: userId);

        String mediaId = data["mediaId"];
        String category = data["category"];

        Map<String, dynamic> media = await getMediaById(mediaId, category);

        return {"id": doc.id, ...data, "username": username, ...media};
      }),
    );

    return reviews;
  } catch (error) {
    print("Error getting popular reviews: $error");
    return [];
  }
}
