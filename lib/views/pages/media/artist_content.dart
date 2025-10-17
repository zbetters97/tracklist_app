import 'package:flutter/material.dart';
import 'package:tracklist_app/data/classes/album_class.dart';
import 'package:tracklist_app/data/classes/artist_class.dart';
import 'package:tracklist_app/data/classes/review_class.dart';
import 'package:tracklist_app/data/classes/track_class.dart';
import 'package:tracklist_app/data/constants.dart';
import 'package:tracklist_app/services/review_service.dart';
import 'package:tracklist_app/services/spotify_service.dart';
import 'package:tracklist_app/views/widgets/media_card_widget.dart';
import 'package:tracklist_app/views/widgets/review_card_widget.dart';

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
  List<Track> singles = [];
  List<Review> reviews = [];

  @override
  void initState() {
    super.initState();
    fetchAlbums();
  }

  void fetchAlbums() async {
    setState(() => isLoading = true);

    List<Album> fetchedAlbums = await getArtistAlbums(artistId: widget.artist.id);

    setState(() {
      albums = fetchedAlbums;
      isLoading = false;
    });
  }

  void fetchSingles() async {
    setState(() => isLoading = true);

    List<Track> fetchedSingles = await getArtistSingles(artistId: widget.artist.id);

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [buildTab(0, "Albums"), buildTab(1, "Singles"), buildTab(2, "Reviews")],
          ),
          currentTab == 0
              ? buildAlbumsList()
              : currentTab == 1
              ? buildSinglesList()
              : buildReviewsList(),
        ],
      ),
    );
  }

  Widget buildTab(int index, String title) {
    return GestureDetector(
      onTap: () => setState(() {
        currentTab = index;

        if (currentTab == 0) {
          fetchAlbums();
        } else if (currentTab == 1) {
          fetchSingles();
        } else if (currentTab == 2) {
          fetchReviews();
        }
      }),
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

  Widget buildAlbumsList() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator(color: PRIMARY_COLOR_DARK));
    }
    if (albums.isEmpty) {
      return Text("No albums found");
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(spacing: 12.0, children: [...albums.map((album) => MediaCardWidget(media: album))]),
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
      child: Column(spacing: 12.0, children: [...singles.map((single) => MediaCardWidget(media: single))]),
    );
  }

  Widget buildReviewsList() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator(color: PRIMARY_COLOR_DARK));
    }
    if (reviews.isEmpty) {
      return Text("No reviews found");
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        spacing: 12.0,
        children: [
          ...reviews.map((review) {
            return Text(review.content);
          }),
        ],
      ),
    );
  }
}
