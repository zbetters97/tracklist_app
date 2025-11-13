import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:tracklist_app/core/utils/notifiers.dart';
import 'package:tracklist_app/core/widgets/loading_icon.dart';
import 'package:tracklist_app/features/user/models/app_user_class.dart';
import 'package:tracklist_app/features/media/models/media_class.dart';
import 'package:tracklist_app/features/review/models/review_class.dart';
import 'package:tracklist_app/core/constants/constants.dart';
import 'package:tracklist_app/features/review/pages/review_likes_page.dart';
import 'package:tracklist_app/features/review/services/review_service.dart';
import 'package:tracklist_app/features/media/pages/media_page.dart';
import 'package:tracklist_app/features/review/content/review_comments_content.dart';
import 'package:tracklist_app/features/user/pages/user_page.dart';
import 'package:tracklist_app/core/widgets/default_app_bar.dart';

class ReviewPage extends StatefulWidget {
  final String reviewId;

  const ReviewPage({super.key, required this.reviewId});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  late Review review;
  late Media media;
  late AppUser user;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchReview();
  }

  void fetchReview() async {
    setState(() => isLoading = true);

    Review fetchedReview = await getReviewById(widget.reviewId);

    setState(() {
      review = fetchedReview;
      media = fetchedReview.media;
      user = fetchedReview.user;
      isLoading = false;
    });
  }

  void onVoteReview(bool isLiked) async {
    setState(() {
      if (isLiked) {
        review.likes.remove(authUser.value!.uid);
        review.likeCount--;
      } else {
        review.likes.add(authUser.value!.uid);
        review.likeCount++;
      }
    });
    await voteReview(review.reviewId);
  }

  void onDeleteReview() async {
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

    bool isReviewDeleted = await deleteReview(review.reviewId);

    if (isReviewDeleted) {
      popPage();
    }
  }

  void popPage() {
    Navigator.pop(context);
  }

  void sendToMediaPage() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => MediaPage(media: media)));
  }

  void sendToUserPage() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => UserPage(uid: user.uid)));
  }

  void sendToLikesPage() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => ReviewLikesPage(review: review)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultAppBar(title: "Review"),
      backgroundColor: BACKGROUND_COLOR,
      body: SingleChildScrollView(
        child: isLoading
            ? LoadingIcon()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildMediaBanner(),
                        const SizedBox(height: 24.0),
                        buildReviewHeader(),
                        const SizedBox(height: 4.0),
                        review.buildContent(20.0),
                        const SizedBox(height: 24.0),
                        buildReviewButtons(),
                      ],
                    ),
                  ),
                  const Divider(color: Colors.white, thickness: 1, height: 0),
                  ReviewCommentsContent(review: review),
                ],
              ),
      ),
    );
  }

  Widget buildMediaBanner() {
    return GestureDetector(
      onTap: () => sendToMediaPage(),
      child: Column(
        spacing: 8.0,
        children: [
          Container(
            decoration: BoxDecoration(
              boxShadow: [BoxShadow(color: Colors.black.withAlpha(75), blurRadius: 12, offset: Offset(0, 4))],
            ),
            child: review.media.buildImage(275),
          ),
          review.media.buildName(review.category, true),
        ],
      ),
    );
  }

  Widget buildReviewHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 8.0,
      children: [
        GestureDetector(onTap: () => sendToUserPage(), child: user.buildProfileImage(context, 30.0)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  style: TextStyle(color: Colors.grey, fontSize: 18),
                  children: [
                    TextSpan(text: "Review by "),
                    TextSpan(
                      text: user.username,
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      recognizer: TapGestureRecognizer()..onTap = () => sendToUserPage(),
                    ),
                  ],
                ),
              ),
              review.buildDateLong(18.0),
              review.buildStarRating(false),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildReviewButtons() {
    bool isPoster = review.user.uid == authUser.value!.uid;

    return Row(
      spacing: 20.0,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        review.buildLikeButtonDetailed(onVoteReview, sendToLikesPage),
        buildShareButton(),
        if (isPoster) review.buildDeleteButton(onDeleteReview),
      ],
    );
  }

  Widget buildShareButton() {
    // TODO: Add functionality to share button
    return Icon(Icons.send, size: 30);
  }
}
