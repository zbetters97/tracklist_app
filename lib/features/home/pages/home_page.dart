import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tracklist_app/core/widgets/empty_text.dart';
import 'package:tracklist_app/core/widgets/loading_icon.dart';
import 'package:tracklist_app/features/review/models/review_class.dart';
import 'package:tracklist_app/core/constants/constants.dart';
import 'package:tracklist_app/features/review/services/review_service.dart';
import 'package:tracklist_app/features/review/widgets/review_card_widget.dart';
import 'package:tracklist_app/navigation/navigator.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentTab = 0;
  bool isLoading = true;

  bool isLoadingNew = false;
  bool isLoadingPopular = false;

  DocumentSnapshot? lastNewReviewDoc;
  DocumentSnapshot? lastPopularReviewDoc;

  final ScrollController newReviewsController = ScrollController();
  final ScrollController popularReviewsController = ScrollController();

  List<Review> newReviews = [];
  List<Review> popularReviews = [];

  @override
  void initState() {
    super.initState();
    getReviews();
    attachListeners();
  }

  void attachListeners() {
    newReviewsController.addListener(() {
      if (newReviewsController.position.pixels >= newReviewsController.position.maxScrollExtent - 200 &&
          !isLoadingNew) {
        loadMoreNewReviews();
      }
    });

    popularReviewsController.addListener(() {
      if (popularReviewsController.position.pixels >= popularReviewsController.position.maxScrollExtent - 200 &&
          !isLoadingPopular) {
        loadMorePopularReviews();
      }
    });
  }

  void getReviews() async {
    if (newReviews.isNotEmpty && popularReviews.isNotEmpty) return;

    setState(() => isLoading = true);

    final List<List<Review>> fetchedReviews = await Future.wait([getFollowingReviews(), getPopularReviews()]);

    // Avoids memory leaks
    if (!mounted) return;

    newReviews = fetchedReviews[0];
    popularReviews = fetchedReviews[1];

    lastNewReviewDoc = newReviews.isNotEmpty ? newReviews.last.doc : null;
    lastPopularReviewDoc = popularReviews.isNotEmpty ? popularReviews.last.doc : null;

    setState(() => isLoading = false);
  }

  void setReviews(int tabIndex) {
    if (currentTab == tabIndex) return;

    setState(() => currentTab = tabIndex);
  }

  Future<void> loadMoreNewReviews() async {
    if (newReviews.isEmpty || isLoadingNew) return;

    setState(() => isLoadingNew = true);

    final List<Review> moreNewReviews = await getFollowingReviews(lastDoc: lastNewReviewDoc);

    if (moreNewReviews.isNotEmpty) {
      setState(() {
        lastNewReviewDoc = moreNewReviews.last.doc;
        newReviews.addAll(moreNewReviews);
      });
    }

    setState(() => isLoadingNew = false);
  }

  Future<void> loadMorePopularReviews() async {
    if (popularReviews.isEmpty || isLoadingPopular) return;

    setState(() => isLoadingPopular = true);

    final List<Review> morePopularReviews = await getPopularReviews(lastDoc: lastPopularReviewDoc);

    if (morePopularReviews.isNotEmpty) {
      setState(() {
        lastPopularReviewDoc = morePopularReviews.last.doc;
        popularReviews.addAll(morePopularReviews);
      });
    }

    setState(() => isLoadingPopular = false);
  }

  Future<void> refreshReviews() async {
    newReviews.clear();
    popularReviews.clear();

    setState(() {
      isLoadingNew = false;
      isLoadingPopular = false;

      lastNewReviewDoc = null;
      lastPopularReviewDoc = null;
    });

    getReviews();
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
      refreshReviews();
    }
  }

  void sendToAddReviewPage() {
    NavigationService().openAddReview();
  }

  @override
  void dispose() {
    newReviewsController.dispose();
    popularReviewsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(children: [buildHero(), buildTopBar(), buildReviews()]),
        buildPostReviewButton(),
      ],
    );
  }

  Widget buildHero() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Hero(
          tag: "TrackList logo",
          child: ClipRRect(
            child: Center(child: Image.asset(LOGO_IMG_LG, height: 50, width: 50, fit: BoxFit.cover)),
          ),
        ),
      ],
    );
  }

  Widget buildTopBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: BACKGROUND_COLOR,
        boxShadow: [
          BoxShadow(color: const Color.fromRGBO(0, 0, 0, 0.3), blurRadius: 3, offset: Offset(0, 6), spreadRadius: 2),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [buildHomeTab(0, "Newest"), SizedBox(width: 30), buildHomeTab(1, "For You")],
      ),
    );
  }

  Widget buildHomeTab(int index, String title) {
    return GestureDetector(
      onTap: () => setReviews(index),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: currentTab == index ? PRIMARY_COLOR : Colors.grey,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Container(
            height: 5,
            width: 100,
            decoration: BoxDecoration(
              color: currentTab == index ? PRIMARY_COLOR : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildReviews() {
    if (isLoading) {
      return const Expanded(child: LoadingIcon());
    }

    return Expanded(
      child: IndexedStack(
        index: currentTab,
        children: [
          newReviews.isEmpty
              ? EmptyText(message: "No reviews found!")
              : buildReviewsList(newReviews, isLoadingNew, newReviewsController),
          popularReviews.isEmpty
              ? EmptyText(message: "No reviews found!")
              : buildReviewsList(popularReviews, isLoadingPopular, popularReviewsController),
        ],
      ),
    );
  }

  Widget buildReviewsList(List<Review> reviews, bool isLoadingMore, ScrollController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: RefreshIndicator.adaptive(
        onRefresh: () async => refreshReviews(),
        color: PRIMARY_COLOR,
        backgroundColor: SECONDARY_COLOR,
        child: ListView.separated(
          controller: controller,
          itemCount: reviews.length + (isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == reviews.length) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(color: PRIMARY_COLOR_DARK),
                ),
              );
            }

            // Route to Review Page on tap using callback
            return ReviewCardWidget(
              review: reviews[index],
              onOpenReview: () => onOpenReview(reviews[index].reviewId),
              onDeleteReview: () => onDeleteReview(reviews[index].reviewId),
            );
          },
          separatorBuilder: (context, index) => const Divider(color: Colors.grey),
        ),
      ),
    );
  }

  Widget buildPostReviewButton() {
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: RawMaterialButton(
          onPressed: () => sendToAddReviewPage(),
          fillColor: PRIMARY_COLOR_DARK,
          shape: CircleBorder(),
          constraints: BoxConstraints.tightFor(width: 65, height: 65),
          child: Icon(Icons.add, size: 40),
        ),
      ),
    );
  }
}
