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
  bool isLoading = true;
  int currentTab = 0;

  List<Artist> artists = [];
  List<Album> albums = [];
  List<Track> tracks = [];
  List<Review> reviews = [];

  final ScrollController reviewsController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchLikes();
  }

  void fetchLikes() async {
    setState(() => isLoading = true);

    List<Artist> fetchedArtists = await getLikedArtists(user.uid);
    List<Album> fetchedAlbums = await getLikedAlbums(user.uid);
    List<Track> fetchedTracks = await getLikedTracks(user.uid);
    List<Review> fetchedReviews = await getLikedReviews(user.uid);

    if (!mounted) return;

    setState(() {
      artists = fetchedArtists;
      albums = fetchedAlbums;
      tracks = fetchedTracks;
      reviews = fetchedReviews;

      isLoading = false;
    });
  }

  void onOpenMedia(Media media) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => MediaPage(media: media)));
  }

  void onOpenReview(String reviewId) {
    NavigationService().openReview(reviewId);
  }

  void onDeleteReview(String reviewId) {
    // TODO: Add delete review functionality
  }

  @override
  void dispose() {
    reviewsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading ? LoadingIcon() : Column(children: [buildTopBar(), buildLikesList()]);
  }

  Widget buildTopBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 16.0,
        children: [
          buildLikesTab(0, "Artists"),
          buildLikesTab(1, "Albums"),
          buildLikesTab(2, "Tracks"),
          buildLikesTab(3, "Reviews"),
        ],
      ),
    );
  }

  Widget buildLikesTab(int index, String title) {
    return GestureDetector(
      onTap: () => setState(() => currentTab = index),
      child: Text(
        title,
        style: TextStyle(
          color: currentTab == index ? PRIMARY_COLOR : Colors.grey,
          fontSize: 24.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget buildLikesList() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: currentTab == 0
            ? buildLikedMediaList(artists, "artists")
            : currentTab == 1
            ? buildLikedMediaList(albums, "albums")
            : currentTab == 2
            ? buildLikedMediaList(tracks, "tracks")
            : buildLikedReviewsList(),
      ),
    );
  }

  Widget buildLikedMediaList(List<Media> media, String category) {
    return media.isEmpty
        ? EmptyText(message: "No liked $category yet!")
        : GridView.builder(
            controller: reviewsController,
            shrinkWrap: true,
            padding: const EdgeInsets.all(0.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 8.0, // Space between rows
              crossAxisSpacing: 8.0, // Space between columns
              childAspectRatio: 0.80, // Larger height to fit name and image
            ),
            itemCount: media.length,
            itemBuilder: (context, index) => MediaCardWidget(media: media[index], onOpenMedia: onOpenMedia),
          );
  }

  Widget buildLikedReviewsList() {
    return reviews.isEmpty
        ? EmptyText(message: "No liked reviews yet!")
        : ListView.separated(
            controller: reviewsController,
            shrinkWrap: true,
            padding: const EdgeInsets.all(0.0),
            itemCount: reviews.length,
            itemBuilder: (context, index) => ReviewCardWidget(
              review: reviews[index],
              onOpenReview: () => onOpenReview(reviews[index].reviewId),
              onDeleteReview: () => onDeleteReview(reviews[index].reviewId),
            ),
            separatorBuilder: (context, index) => const Divider(color: Colors.grey),
          );
  }
}
