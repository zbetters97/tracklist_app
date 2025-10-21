import 'package:flutter/material.dart';
import 'package:tracklist_app/data/models/album_class.dart';
import 'package:tracklist_app/data/models/artist_class.dart';
import 'package:tracklist_app/data/models/review_class.dart';
import 'package:tracklist_app/core/constants/constants.dart';
import 'package:tracklist_app/data/sources/review_service.dart';
import 'package:tracklist_app/data/sources/spotify_service.dart';
import 'package:tracklist_app/features/media/pages/media_page.dart';
import 'package:tracklist_app/features/media/content/media_reviews_content.dart';
import 'package:tracklist_app/features/media/widgets/media_card_widget.dart';

class ArtistContent extends StatefulWidget {
  const ArtistContent({super.key, required this.artist});

  final Artist artist;

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
              ? Center(child: CircularProgressIndicator(color: PRIMARY_COLOR_DARK))
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
          SizedBox(height: 5),
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

  void switchTab(int index) {
    setState(() {
      if (currentTab == index) return;

      currentTab = index;

      currentTab == 0
          ? fetchAlbums()
          : currentTab == 1
          ? fetchSingles()
          : fetchReviews();
    });
  }

  Widget buildAlbumsList() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator(color: PRIMARY_COLOR_DARK));
    }
    if (albums.isEmpty) {
      return Text("No albums found");
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        spacing: 12.0,
        children: [
          ...albums.map(
            (album) => GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => MediaPage(media: album)));
              },
              child: MediaCardWidget(media: album),
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
      return Text("No singles found");
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        spacing: 12.0,
        children: [
          ...singles.map(
            (single) => GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => MediaPage(media: single)));
              },
              child: MediaCardWidget(media: single),
            ),
          ),
        ],
      ),
    );
  }
}
