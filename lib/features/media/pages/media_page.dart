import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tracklist_app/core/utils/color.dart';
import 'package:tracklist_app/data/models/album_class.dart';
import 'package:tracklist_app/data/models/artist_class.dart';
import 'package:tracklist_app/data/models/media_class.dart';
import 'package:tracklist_app/data/models/review_class.dart';
import 'package:tracklist_app/data/models/track_class.dart';
import 'package:tracklist_app/core/constants/constants.dart';
import 'package:tracklist_app/data/sources/review_service.dart';
import 'package:tracklist_app/data/sources/spotify_service.dart';
import 'package:tracklist_app/features/media/content/album_content.dart';
import 'package:tracklist_app/features/media/content/artist_content.dart';
import 'package:tracklist_app/features/media/content/track_content.dart';
import 'package:tracklist_app/core/widgets/my_app_bar.dart';
import 'package:tracklist_app/features/media/widgets/ratings_bar_widget.dart';
import 'package:tracklist_app/core/widgets/stars_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class MediaPage extends StatefulWidget {
  const MediaPage({super.key, required this.media});

  final Media media;

  @override
  State<MediaPage> createState() => _MediaPageState();
}

class _MediaPageState extends State<MediaPage> {
  Media get media => widget.media;
  Color bgColorA = BACKGROUND_COLOR;
  Color bgColorB = BACKGROUND_COLOR;

  bool isLoading = true;
  List<Review> reviews = [];
  double avgRating = 0.0;
  late QuerySnapshot reviewDocs;
  int totalReviews = 0;

  @override
  void initState() {
    super.initState();
    fetchReviews();
  }

  void fetchReviews() async {
    setState(() => isLoading = true);

    List<Review> fetchedReviews = await getReviewsByMediaId(media.id);
    double fetchedAvgRating = await getAvgRating(media.id);
    QuerySnapshot fetchedReviewDocs = await getReviewDocsByMediaId(media.id);

    await getMediaColor(media.image);

    setState(() {
      reviews = fetchedReviews;
      avgRating = fetchedAvgRating;
      reviewDocs = fetchedReviewDocs;
      isLoading = false;
    });
  }

  Future<void> getMediaColor(String imageUrl) async {
    final palette = await getColors(imageUrl);

    setState(() {
      bgColorA = palette.light;
      bgColorB = palette.dark;
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

  void sendToMediaPage(BuildContext content, String artistId) async {
    final navigator = Navigator.of(content);
    final Artist artist = await getArtistById(artistId);

    navigator.push(MaterialPageRoute(builder: (_) => MediaPage(media: artist)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: media.name),
      backgroundColor: BACKGROUND_COLOR,
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: PRIMARY_COLOR_DARK))
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    decoration: buildMediaGradient(),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 275 + 75 + 75, // Image height + Ratings Bar height + gap height
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                buildMediaImage(media),
                                Positioned(
                                  top: 275 + 75, // Image height + Ratings Bar height
                                  left: 0,
                                  right: 0,
                                  height: 75, // Fixed height of 75
                                  child: RatingsBar(reviews: reviewDocs),
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
                    ),
                  ),
                  if (media is Artist) ArtistContent(artist: media as Artist),
                  if (media is Album) AlbumContent(album: media as Album),
                  if (media is Track) TrackContent(track: media as Track),
                ],
              ),
            ),
    );
  }

  BoxDecoration buildMediaGradient() {
    return BoxDecoration(
      gradient: LinearGradient(colors: [bgColorA, bgColorB], begin: Alignment.topLeft, end: Alignment.bottomRight),
    );
  }

  Widget buildMediaImage(Media media) {
    return Column(
      children: [
        GestureDetector(
          onTap: () async => launchSpotify(media.spotify),
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [BoxShadow(color: Colors.black.withAlpha(125), blurRadius: 12, offset: Offset(0, 4))],
            ),
            child: Image.network(media.image, width: 275, height: 275, fit: BoxFit.cover),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          media.name,
          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        if (media is Album || media is Track)
          GestureDetector(
            onTap: () async => sendToMediaPage(context, (media as dynamic).artistId),
            child: Text(
              (media as dynamic).artist,
              style: const TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }

  Widget buildMediaReviews(double avgRating, int totalReviews) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          avgRating.toString(),
          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 5),
        StarRating(rating: avgRating),
        const SizedBox(width: 5),
        Text(
          "(${totalReviews.toString()})",
          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
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
