import 'package:flutter/material.dart';
import 'package:tracklist_app/core/constants/constants.dart';
import 'package:tracklist_app/features/auth/models/app_user_class.dart';
import 'package:tracklist_app/features/home/widgets/home_review_widget.dart';
import 'package:tracklist_app/features/review/models/review_class.dart';
import 'package:tracklist_app/features/review/services/review_service.dart';
import 'package:tracklist_app/navigation/navigator.dart';

class UserReviewsSection extends StatefulWidget {
  const UserReviewsSection({super.key, required this.user});

  final AppUser user;

  @override
  State<UserReviewsSection> createState() => _UserReviewsSectionState();
}

class _UserReviewsSectionState extends State<UserReviewsSection> {
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

    setState(() {
      reviews = fetchedReviews;
      isLoading = false;
    });
  }

  @override
  void dispose() {
    reviewsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading ? const Center(child: CircularProgressIndicator(color: PRIMARY_COLOR_DARK)) : buildUserReviews();
  }

  Widget buildUserReviews() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView.separated(
        controller: reviewsController,
        shrinkWrap: true,
        padding: const EdgeInsets.all(0.0),
        itemCount: reviews.length,
        itemBuilder: (context, index) {
          // Route to Review Page on tap using callback
          return HomeReviewWidget(
            review: reviews[index],
            onOpenReview: () => NavigationService().openReview(reviews[index].reviewId),
          );
        },
        separatorBuilder: (context, index) => const Divider(color: Colors.grey),
      ),
    );
  }
}
