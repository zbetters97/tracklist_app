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
  bool _isLoading = true;
  int _currentTab = 0;

  List<Album> _albums = [];
  List<Album> _singles = [];
  List<Review> _reviews = [];

  @override
  void initState() {
    super.initState();
    _fetchAlbums();
  }

  void _fetchAlbums() async {
    setState(() => _isLoading = true);

    List<Album> fetchedAlbums = await getArtistAlbums(widget.artist.id);

    setState(() {
      _albums = fetchedAlbums;
      _isLoading = false;
    });
  }

  void _fetchSingles() async {
    setState(() => _isLoading = true);

    List<Album> fetchedSingles = await getArtistSingles(widget.artist.id);

    setState(() {
      _singles = fetchedSingles;
      _isLoading = false;
    });
  }

  void _fetchReviews() async {
    setState(() => _isLoading = true);

    List<Review> fetchedReviews = await getReviewsByMediaId(widget.artist.id);

    setState(() {
      _reviews = fetchedReviews;
      _isLoading = false;
    });
  }

  void _switchTab(int index) {
    if (_currentTab == index) return;

    setState(() {
      _currentTab = index;

      _currentTab == 0
          ? _fetchAlbums()
          : _currentTab == 1
          ? _fetchSingles()
          : _fetchReviews();
    });
  }

  void _sendToMediaPage(Album album) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => MediaPage(media: album)));
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
              children: [_buildTab(0, "Albums"), _buildTab(1, "Singles"), _buildTab(2, "Reviews")],
            ),
          ),
          _isLoading
              ? LoadingIcon()
              : _currentTab == 0
              ? _buildAlbumsList()
              : _currentTab == 1
              ? _buildSinglesList()
              : MediaReviews(reviews: _reviews),
        ],
      ),
    );
  }

  Widget _buildTab(int index, String title) {
    return GestureDetector(
      onTap: () => _switchTab(index),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: _currentTab == index ? PRIMARY_COLOR : Colors.grey,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
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

  Widget _buildAlbumsList() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: PRIMARY_COLOR_DARK));
    }
    if (_albums.isEmpty) {
      return EmptyText(message: "No albums found!");
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        spacing: 12.0,
        children: [
          ..._albums.map(
            (album) => GestureDetector(
              onTap: () => _sendToMediaPage(album),
              child: RatedMediaCardWidget(media: album),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSinglesList() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: PRIMARY_COLOR_DARK));
    }
    if (_singles.isEmpty) {
      return EmptyText(message: "No singles found!");
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        spacing: 12.0,
        children: [
          ..._singles.map(
            (single) => GestureDetector(
              onTap: () => _sendToMediaPage(single),
              child: RatedMediaCardWidget(media: single),
            ),
          ),
        ],
      ),
    );
  }
}
