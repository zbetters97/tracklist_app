import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tracklist_app/services/auth_service.dart';
import 'package:tracklist_app/services/spotify_service.dart';

final FirebaseFirestore firestore = FirebaseFirestore.instance;

Future<List<Map<String, dynamic>>> getPopularReviews() async {
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

        Map<String, dynamic> media = category == "artist"
            ? await getArtistById(mediaId)
            : category == "album"
            ? await getAlbumById(mediaId)
            : await getTrackById(mediaId);

        return {
          "id": doc.id,
          "category": data["category"],
          "content": data["content"],
          "createdAt": data["createdAt"],
          "dislikes": data["dislikes"],
          "likes": data["likes"],
          "rating": data["rating"],
          "username": username,
          ...media,
        };
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
