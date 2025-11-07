import 'package:flutter/material.dart';
import 'package:tracklist_app/core/widgets/empty_text.dart';
import 'package:tracklist_app/core/widgets/loading_icon.dart';
import 'package:tracklist_app/features/media/models/album_class.dart';
import 'package:tracklist_app/features/media/models/artist_class.dart';
import 'package:tracklist_app/features/review/models/review_class.dart';
import 'package:tracklist_app/core/constants/constants.dart';
import 'package:tracklist_app/features/review/services/review_service.dart';
import 'package:tracklist_app/features/media/services/spotify_service.dart';
import 'package:tracklist_app/features/media/pages/media_page.dart';
import 'package:tracklist_app/features/media/content/media_reviews_content.dart';
import 'package:tracklist_app/features/media/widgets/rated_media_card_widget.dart';

class ArtistContent extends StatefulWidget {
  final Artist artist;

  const ArtistContent({super.key, required this.artist});

  @override
  State<ArtistContent> createState() => _ArtistContentState();
}

class _ArtistContentState extends State<ArtistContent> {
  bool isLoading = true;
  int currentTab = 0;

  List<Album> albums = [];
  List<Album> singles = [];
  List<Review> reviews = [];

  @override
  void initState() {
    super.initState();
    fetchAlbums();
  }

  void fetchAlbums() async {
    setState(() => isLoading = true);

    List<Album> fetchedAlbums = await getArtistAlbums(widget.artist.id);

    setState(() {
      albums = fetchedAlbums;
      isLoading = false;
    });
  }

  void fetchSingles() async {
    setState(() => isLoading = true);

    List<Album> fetchedSingles = await getArtistSingles(widget.artist.id);

    setState(() {
      singles = fetchedSingles;
      isLoading = false;
    });
  }

  void fetchReviews() async {
    setState(() => isLoading = true);

    List<Review> fetchedReviews = await getReviewsByMediaId(widget.artist.id);

    setState(() {
      reviews = fetchedReviews;
      isLoading = false;
    });
  }

  void switchTab(int index) {
    if (currentTab == index) return;

    setState(() {
      currentTab = index;

      currentTab == 0
          ? fetchAlbums()
          : currentTab == 1
          ? fetchSingles()
          : fetchReviews();
    });
  }

  void sendToMediaPage(Album album) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => MediaPage(media: album)));
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [buildTabs()]);
  }

  Widget buildTabs() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [buildTab(0, "Albums"), buildTab(1, "Singles"), buildTab(2, "Reviews")],
            ),
          ),
          isLoading
              ? LoadingIcon()
              : currentTab == 0
              ? buildAlbumsList()
              : currentTab == 1
              ? buildSinglesList()
              : MediaReviews(reviews: reviews),
        ],
      ),
    );
  }

  Widget buildTab(int index, String title) {
    return GestureDetector(
      onTap: () => switchTab(index),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: currentTab == index ? PRIMARY_COLOR : Colors.grey,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Container(
            height: 5,
            width: 85,
            decoration: BoxDecoration(
              color: currentTab == index ? PRIMARY_COLOR : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildAlbumsList() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator(color: PRIMARY_COLOR_DARK));
    }
    if (albums.isEmpty) {
      return EmptyText(message: "No albums found!");
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        spacing: 12.0,
        children: [
          ...albums.map(
            (album) => GestureDetector(
              onTap: () => sendToMediaPage(album),
              child: RatedMediaCardWidget(media: album),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSinglesList() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator(color: PRIMARY_COLOR_DARK));
    }
    if (singles.isEmpty) {
      return EmptyText(message: "No singles found!");
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        spacing: 12.0,
        children: [
          ...singles.map(
            (single) => GestureDetector(
              onTap: () => sendToMediaPage(single),
              child: RatedMediaCardWidget(media: single),
            ),
          ),
        ],
      ),
    );
  }
}
