import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tracklist_app/data/classes/media_class.dart';
import 'package:tracklist_app/data/classes/review_class.dart';
import 'package:tracklist_app/data/constants.dart';
import 'package:tracklist_app/services/review_service.dart';
import 'package:tracklist_app/views/widgets/my_app_bar.dart';
import 'package:tracklist_app/views/widgets/rating_bar_widget.dart';
import 'package:tracklist_app/views/widgets/stars_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class ArtistPage extends StatefulWidget {
  const ArtistPage({super.key, required this.media});

  final Media media;

  @override
  State<ArtistPage> createState() => _ArtistPageState();
}

class _ArtistPageState extends State<ArtistPage> {
  Media get media => widget.media;

  bool isLoading = true;
  List<Review> reviews = [];
  double avgRating = 0.0;
  late QuerySnapshot ratings;
  int totalReviews = 0;

  @override
  void initState() {
    super.initState();
    fetchReviews();
  }

  void fetchReviews() async {
    setState(() {
      isLoading = true;
    });

    List<Review> fetchedReviews = await getReviewsByMediaId(media.id);
    double fetchedAvgRating = await getAvgRating(media.id);
    QuerySnapshot fetchedRatings = await getRatings(media.id);

    setState(() {
      reviews = fetchedReviews;
      avgRating = fetchedAvgRating;
      ratings = fetchedRatings;
      isLoading = false;
    });
  }

  void launchSpotify(String spotifyUrl) async {
    final Uri spotifyUri = Uri.parse(spotifyUrl);

    // Check if URL can be launched
    if (await canLaunchUrl(spotifyUri)) {
      // Attempt to launch Spotify URL in external app
      await launchUrl(spotifyUri, mode: LaunchMode.externalApplication);
    } else {
      // Failed to launch Spotify URL
      throw 'Could not launch Spotify';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: media.name),
      backgroundColor: BACKGROUND_COLOR,
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: PRIMARY_COLOR_DARK))
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        SizedBox(
                          height: 275 + 75 + 75,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              buildMediaImage(media.spotify, media.image, media.name),
                              Positioned(
                                top: 275 + 75,
                                left: 0,
                                right: 0,
                                child: RatingBar(ratings: ratings),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        buildMediaReviews(avgRating, reviews.length),
                        const SizedBox(height: 20),
                        buildMediaButtons(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget buildMediaImage(String spotifyUrl, String imageUrl, String name) {
    return GestureDetector(
      onTap: () async => launchSpotify(spotifyUrl),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              boxShadow: [BoxShadow(color: Colors.black.withAlpha(75), blurRadius: 12, offset: Offset(0, 4))],
            ),
            child: Image.network(imageUrl, width: 275, height: 275, fit: BoxFit.cover),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget buildMediaReviews(double avgRating, int totalReviews) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              avgRating.toString(),
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 5),
            buildStarRating(avgRating),
            const SizedBox(width: 5),
            Text(
              "(${totalReviews.toString()})",
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildMediaButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Icon(Icons.favorite, color: Colors.white, size: 30),
        Icon(Icons.edit_square, color: Colors.white, size: 30),
        Icon(Icons.format_list_bulleted, color: Colors.white, size: 30),
        Icon(Icons.send, color: Colors.white, size: 30),
      ],
    );
  }
}
