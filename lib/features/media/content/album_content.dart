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
  bool _isLoading = true;
  int _currentTab = 0;

  List<Track> _tracks = [];
  List<Review> _reviews = [];

  @override
  void initState() {
    super.initState();
    _fetchTracks();
  }

  void _fetchTracks() async {
    setState(() => _isLoading = true);

    List<Track> fetchedTracks = await getAlbumTracks(widget.album.id, widget.album);

    setState(() {
      _tracks = fetchedTracks;
      _isLoading = false;
    });
  }

  void _fetchReviews() async {
    setState(() => _isLoading = true);

    List<Review> fetchedReviews = await getReviewsByMediaId(widget.album.id);

    setState(() {
      _reviews = fetchedReviews;
      _isLoading = false;
    });
  }

  void _switchTab(int index) {
    if (_currentTab == index) return;

    setState(() {
      _currentTab = index;
      _currentTab == 0 ? _fetchTracks() : _fetchReviews();
    });
  }

  void _sendToMediaPage(Track track) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => MediaPage(media: track)));
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [__buildTabs()]);
  }

  Widget __buildTabs() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [_buildTab(0, "Tracks"), _buildTab(1, "Reviews")],
            ),
          ),
          _isLoading
              ? LoadingIcon()
              : _currentTab == 0
              ? _buildTracksList()
              : MediaReviews(reviews: _reviews),
        ],
      ),
    );
  }

  Widget _buildTab(int index, String title) {
    return GestureDetector(
      onTap: () => _switchTab(index),
      child: Column(
        spacing: 5.0,
        children: [
          Text(
            title,
            style: TextStyle(
              color: _currentTab == index ? PRIMARY_COLOR : Colors.grey,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            height: 5,
            width: 85,
            decoration: BoxDecoration(
              color: _currentTab == index ? PRIMARY_COLOR : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTracksList() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: PRIMARY_COLOR_DARK));
    }
    if (_tracks.isEmpty) {
      return EmptyText(message: "No tracks found!");
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        spacing: 16.0,
        children: [
          ..._tracks.map(
            (track) => GestureDetector(
              onTap: () => _sendToMediaPage(track),
              child: TrackCardWidget(track: track),
            ),
          ),
        ],
      ),
    );
  }
}
