import 'package:flutter/material.dart';
import 'package:tracklist_app/core/constants/constants.dart';
import 'package:tracklist_app/core/widgets/empty_text.dart';
import 'package:tracklist_app/core/widgets/loading_icon.dart';
import 'package:tracklist_app/features/media/models/album_class.dart';
import 'package:tracklist_app/features/media/models/artist_class.dart';
import 'package:tracklist_app/features/media/models/media_class.dart';
import 'package:tracklist_app/features/media/models/track_class.dart';
import 'package:tracklist_app/features/media/pages/media_page.dart';
import 'package:tracklist_app/features/media/widgets/media_card_widget.dart';
import 'package:tracklist_app/features/review/models/review_class.dart';
import 'package:tracklist_app/features/review/services/review_service.dart';
import 'package:tracklist_app/features/review/widgets/review_card_widget.dart';
import 'package:tracklist_app/features/user/models/app_user_class.dart';
import 'package:tracklist_app/features/user/services/user_service.dart';
import 'package:tracklist_app/navigation/navigator.dart';

class UserLikesContent extends StatefulWidget {
  final AppUser user;

  const UserLikesContent({super.key, required this.user});

  @override
  State<UserLikesContent> createState() => _UserLikesContentState();
}

class _UserLikesContentState extends State<UserLikesContent> {
  AppUser get user => widget.user;
  bool _isLoading = true;
  int _currentTab = 0;

  List<Artist> _artists = [];
  List<Album> _albums = [];
  List<Track> _tracks = [];
  List<Review> _reviews = [];

  final ScrollController _reviewsController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchLikes();
  }

  @override
  void dispose() {
    _reviewsController.dispose();
    super.dispose();
  }

  void _fetchLikes() async {
    setState(() => _isLoading = true);

    List<Artist> fetchedArtists = await getLikedArtists(user.uid);
    List<Album> fetchedAlbums = await getLikedAlbums(user.uid);
    List<Track> fetchedTracks = await getLikedTracks(user.uid);
    List<Review> fetchedReviews = await getLikedReviews(user.uid);

    if (!mounted) return;

    setState(() {
      _artists = fetchedArtists;
      _albums = fetchedAlbums;
      _tracks = fetchedTracks;
      _reviews = fetchedReviews;

      _isLoading = false;
    });
  }

  void _onOpenMedia(Media media) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => MediaPage(media: media)));
  }

  void _onOpenReview(String reviewId) {
    NavigationService().openReview(reviewId);
  }

  void _onDeleteReview(String reviewId) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Review"),
        content: const Text("Are you sure you want to delete this review?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete")),
        ],
      ),
    );

    if (!confirm! || !mounted) return;

    bool isReviewDeleted = await deleteReview(reviewId);

    if (isReviewDeleted) {
      _fetchLikes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading ? LoadingIcon() : Column(children: [_buildTopBar(), _buildLikesList()]);
  }

  Widget _buildTopBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 20.0,
          children: [
            _buildLikesTab(0, "Artists"),
            _buildLikesTab(1, "Albums"),
            _buildLikesTab(2, "Tracks"),
            _buildLikesTab(3, "Reviews"),
          ],
        ),
      ),
    );
  }

  Widget _buildLikesTab(int index, String title) {
    return GestureDetector(
      onTap: () => setState(() => _currentTab = index),
      child: Text(
        title,
        style: TextStyle(
          color: _currentTab == index ? PRIMARY_COLOR : Colors.grey,
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildLikesList() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _currentTab == 0
            ? _buildLikedMediaList(_artists, "artists")
            : _currentTab == 1
            ? _buildLikedMediaList(_albums, "albums")
            : _currentTab == 2
            ? _buildLikedMediaList(_tracks, "tracks")
            : _buildLikedReviewsList(),
      ),
    );
  }

  Widget _buildLikedMediaList(List<Media> media, String category) {
    return media.isEmpty
        ? EmptyText(message: "No liked $category yet!")
        : GridView.builder(
            controller: _reviewsController,
            shrinkWrap: true,
            padding: const EdgeInsets.all(0.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 8.0, // Space between rows
              crossAxisSpacing: 8.0, // Space between columns
              childAspectRatio: 0.80, // Larger height to fit name and image
            ),
            itemCount: media.length,
            itemBuilder: (context, index) => MediaCardWidget(media: media[index], onOpenMedia: _onOpenMedia),
          );
  }

  Widget _buildLikedReviewsList() {
    return _reviews.isEmpty
        ? EmptyText(message: "No liked reviews yet!")
        : ListView.separated(
            controller: _reviewsController,
            shrinkWrap: true,
            padding: const EdgeInsets.all(0.0),
            itemCount: _reviews.length,
            itemBuilder: (context, index) => ReviewCardWidget(
              review: _reviews[index],
              onOpenReview: () => _onOpenReview(_reviews[index].reviewId),
              onDeleteReview: () => _onDeleteReview(_reviews[index].reviewId),
            ),
            separatorBuilder: (context, index) => const Divider(color: Colors.grey),
          );
  }
}
