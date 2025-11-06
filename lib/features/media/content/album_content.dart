import 'package:flutter/material.dart';
import 'package:tracklist_app/core/widgets/empty_text.dart';
import 'package:tracklist_app/core/widgets/loading_icon.dart';
import 'package:tracklist_app/features/media/models/album_class.dart';
import 'package:tracklist_app/features/review/models/review_class.dart';
import 'package:tracklist_app/features/media/models/track_class.dart';
import 'package:tracklist_app/core/constants/constants.dart';
import 'package:tracklist_app/features/review/services/review_service.dart';
import 'package:tracklist_app/features/media/services/spotify_service.dart';
import 'package:tracklist_app/features/media/content/media_reviews_content.dart';
import 'package:tracklist_app/features/media/pages/media_page.dart';
import 'package:tracklist_app/features/media/widgets/track_card_widget.dart';

class AlbumContent extends StatefulWidget {
  final Album album;

  const AlbumContent({super.key, required this.album});

  @override
  State<AlbumContent> createState() => _AlbumContentState();
}

class _AlbumContentState extends State<AlbumContent> {
  bool isLoading = true;
  int currentTab = 0;

  List<Track> tracks = [];
  List<Review> reviews = [];

  @override
  void initState() {
    super.initState();
    fetchTracks();
  }

  void fetchTracks() async {
    setState(() => isLoading = true);

    List<Track> fetchedTracks = await getAlbumTracks(widget.album.id, widget.album);

    setState(() {
      tracks = fetchedTracks;
      isLoading = false;
    });
  }

  void fetchReviews() async {
    setState(() => isLoading = true);

    List<Review> fetchedReviews = await getReviewsByMediaId(widget.album.id);

    setState(() {
      reviews = fetchedReviews;
      isLoading = false;
    });
  }

  void switchTab(int index) {
    if (currentTab == index) return;

    setState(() {
      currentTab = index;
      currentTab == 0 ? fetchTracks() : fetchReviews();
    });
  }

  void sendToMediaPage(Track track) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => MediaPage(media: track)));
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
              children: [buildTab(0, "Tracks"), buildTab(1, "Reviews")],
            ),
          ),
          isLoading
              ? LoadingIcon()
              : currentTab == 0
              ? buildTracksList()
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

  Widget buildTracksList() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator(color: PRIMARY_COLOR_DARK));
    }
    if (tracks.isEmpty) {
      return EmptyText(message: "No tracks found!");
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        spacing: 16.0,
        children: [
          ...tracks.map(
            (track) => GestureDetector(
              onTap: () => sendToMediaPage(track),
              child: TrackCardWidget(track: track),
            ),
          ),
        ],
      ),
    );
  }
}
