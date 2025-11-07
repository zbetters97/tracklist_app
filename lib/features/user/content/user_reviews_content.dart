import 'package:flutter/material.dart';
import 'package:tracklist_app/core/widgets/empty_text.dart';
import 'package:tracklist_app/core/widgets/loading_icon.dart';
import 'package:tracklist_app/features/review/widgets/review_card_widget.dart';
import 'package:tracklist_app/features/user/models/app_user_class.dart';
import 'package:tracklist_app/features/review/models/review_class.dart';
import 'package:tracklist_app/features/review/services/review_service.dart';
import 'package:tracklist_app/navigation/navigator.dart';

class UserReviewsContent extends StatefulWidget {
  final AppUser user;

  const UserReviewsContent({super.key, required this.user});

  @override
  State<UserReviewsContent> createState() => _UserReviewsContentState();
}

class _UserReviewsContentState extends State<UserReviewsContent> {
  AppUser get user => widget.user;
  List<Review> reviews = [];
  bool isLoading = true;

  final ScrollController reviewsController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchReviews();
  }

  void fetchReviews() async {
    setState(() => isLoading = true);

    List<Review> fetchedReviews = await getReviewsByUserId(user.uid);

    if (!mounted) return;

    setState(() {
      reviews = fetchedReviews;
      isLoading = false;
    });
  }

  void onOpenReview(String reviewId) {
    NavigationService().openReview(reviewId);
  }

  void onDeleteReview(String reviewId) async {
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
      fetchReviews();
    }
  }

  @override
  void dispose() {
    reviewsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading ? LoadingIcon() : buildUserReviews();
  }

  Widget buildUserReviews() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: reviews.isEmpty
          ? EmptyText(message: "No reviews yet!")
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
            ),
    );
  }
}
