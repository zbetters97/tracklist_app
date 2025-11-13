import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tracklist_app/core/utils/color.dart';
import 'package:tracklist_app/core/widgets/loading_icon.dart';
import 'package:tracklist_app/features/media/models/album_class.dart';
import 'package:tracklist_app/features/media/models/artist_class.dart';
import 'package:tracklist_app/features/media/models/media_class.dart';
import 'package:tracklist_app/features/review/models/review_class.dart';
import 'package:tracklist_app/features/media/models/track_class.dart';
import 'package:tracklist_app/core/constants/constants.dart';
import 'package:tracklist_app/features/review/services/review_service.dart';
import 'package:tracklist_app/features/media/services/spotify_service.dart';
import 'package:tracklist_app/features/media/content/album_content.dart';
import 'package:tracklist_app/features/media/content/artist_content.dart';
import 'package:tracklist_app/features/media/content/track_content.dart';
import 'package:tracklist_app/core/widgets/default_app_bar.dart';
import 'package:tracklist_app/features/media/widgets/ratings_bar_widget.dart';
import 'package:tracklist_app/core/widgets/stars_widget.dart';
import 'package:tracklist_app/features/user/services/user_service.dart';
import 'package:tracklist_app/navigation/navigator.dart';
import 'package:url_launcher/url_launcher.dart';

class MediaPage extends StatefulWidget {
  final Media media;

  const MediaPage({super.key, required this.media});

  @override
  State<MediaPage> createState() => _MediaPageState();
}

class _MediaPageState extends State<MediaPage> {
  Media get media => widget.media;
  Color bgColorA = BACKGROUND_COLOR;
  Color bgColorB = BACKGROUND_COLOR;

  bool isLoading = true;
  String category = "";
  List<Review> reviews = [];
  double avgRating = 0.0;
  late QuerySnapshot reviewDocs;
  int totalReviews = 0;
  bool isLiked = false;

  @override
  void initState() {
    super.initState();
    fetchReviews();
  }

  void fetchReviews() async {
    setState(() => isLoading = true);

    category = media.getCategory();
    isLiked = await getIsLikedContent(media.id, category);

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

  void likeMedia() async {
    await likeContent(media.id, category);
    setState(() => isLiked = !isLiked);
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

  void sendToAddReviewPage() {
    NavigationService().openAddReview(media: media);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultAppBar(title: media.name),
      backgroundColor: BACKGROUND_COLOR,
      body: isLoading
          ? LoadingIcon()
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
                          buildMediaHeader(),
                          const SizedBox(height: 12),
                          buildMediaReviews(),
                          const SizedBox(height: 20),
                          buildMediaButtons(),
                        ],
                      ),
                    ),
                  ),
                  buildMediaContent(),
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

  Widget buildMediaHeader() {
    return SizedBox(
      height: 275 + 75 + 75, // Image height + Ratings Bar height + gap height
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          buildMediaImage(),
          Positioned(
            top: 275 + 75, // Image height + Ratings Bar height
            left: 0,
            right: 0,
            height: 75, // Fixed height of 75
            child: RatingsBar(reviews: reviewDocs),
          ),
        ],
      ),
    );
  }

  Widget buildMediaImage() {
    return Column(
      children: [
        GestureDetector(
          onTap: () async => launchSpotify(media.spotify),
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [BoxShadow(color: Colors.black.withAlpha(125), blurRadius: 12, offset: Offset(0, 4))],
            ),
            child: media.buildImage(275),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          media.name,
          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        if (media.getCategory() != "artist")
          GestureDetector(
            onTap: () async => sendToMediaPage(context, (media as dynamic).artistId),
            child: Text(
              (media as dynamic).artist,
              style: const TextStyle(color: Colors.grey, fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }

  Widget buildMediaReviews() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 5.0,
      children: [
        Text(
          avgRating.toString(),
          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        StarRating(rating: avgRating),
        Text(
          "(${reviews.length.toString()})",
          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget buildMediaButtons() {
    // TODO: Add functionality to media buttons

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        buildLikeButton(),
        buildReviewButton(),
        Icon(Icons.format_list_bulleted, color: Colors.white, size: 30),
        Icon(Icons.send, color: Colors.white, size: 30),
      ],
    );
  }

  Widget buildLikeButton() {
    return GestureDetector(
      onTap: () => likeMedia(),
      child: Icon(Icons.favorite, color: isLiked ? PRIMARY_COLOR_LIGHT : Colors.white, size: 30),
    );
  }

  Widget buildReviewButton() {
    return GestureDetector(
      onTap: () => sendToAddReviewPage(),
      child: Icon(Icons.edit_square, color: Colors.white, size: 30),
    );
  }

  Widget buildMediaContent() {
    Widget content = category == "artist"
        ? ArtistContent(artist: media as Artist)
        : category == "album"
        ? AlbumContent(album: media as Album)
        : category == "track"
        ? TrackContent(track: media as Track)
        : Container();

    return content;
  }
}
