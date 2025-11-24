import 'package:flutter/material.dart';
import 'package:tracklist_app/core/constants/constants.dart';
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
  List<Review> _reviews = [];
  bool _isLoading = true;

  final ScrollController _reviewsController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  @override
  void dispose() {
    _reviewsController.dispose();
    super.dispose();
  }

  void _fetchReviews() async {
    setState(() => _isLoading = true);

    List<Review> fetchedReviews = await getReviewsByUserId(user.uid);

    if (!mounted) return;

    setState(() {
      _reviews = fetchedReviews;
      _isLoading = false;
    });
  }

  void _sendToAddReviewPage() {
    NavigationService().openAddReview();
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
      _fetchReviews();
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading ? LoadingIcon() : Stack(children: [_buildUserReviews(), _buildPostReviewButton()]);
  }

  Widget _buildUserReviews() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: _reviews.isEmpty
          ? EmptyText(message: "No reviews yet!")
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
            ),
    );
  }

  Widget _buildPostReviewButton() {
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: RawMaterialButton(
          onPressed: () => _sendToAddReviewPage(),
          fillColor: PRIMARY_COLOR_DARK,
          shape: CircleBorder(),
          constraints: BoxConstraints.tightFor(width: 65, height: 65),
          child: Icon(Icons.add, size: 40),
        ),
      ),
    );
  }
}
