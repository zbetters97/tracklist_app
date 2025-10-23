import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tracklist_app/data/models/review_class.dart';
import 'package:tracklist_app/core/constants/constants.dart';
import 'package:tracklist_app/data/sources/review_service.dart';
import 'package:tracklist_app/core/widgets/review_card_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.onOpenReview});

  // Callback to open the review page
  final void Function(Review review) onOpenReview;

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

    final List<List<Review>> fetchedReviews = await Future.wait([getNewReviews(), getPopularReviews()]);

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

    final List<Review> moreNewReviews = await getNewReviews(lastDoc: lastNewReviewDoc);

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
        Column(
          children: [
            buildHero(),
            buildTopBar(),
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator(color: PRIMARY_COLOR_DARK))
                  : IndexedStack(
                      index: currentTab,
                      children: [
                        newReviews.isEmpty
                            ? buildEmptyReviewsMessage()
                            : buildReviewsList(newReviews, isLoadingNew, newReviewsController),
                        popularReviews.isEmpty
                            ? buildEmptyReviewsMessage()
                            : buildReviewsList(popularReviews, isLoadingPopular, popularReviewsController),
                      ],
                    ),
            ),
          ],
        ),
        buildPostReviewButton(),
      ],
    );
  }

  Widget buildHero() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Hero(
          tag: "tracklist logo",
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
          SizedBox(height: 5),
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

  Widget buildEmptyReviewsMessage() {
    return Center(
      child: Text(
        "No reviews found!",
        style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic, fontSize: 24),
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
            return GestureDetector(
              onTap: () => widget.onOpenReview(reviews[index]),
              child: ReviewCardWidget(review: reviews[index]),
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
          onPressed: () {},
          fillColor: PRIMARY_COLOR_DARK,
          shape: CircleBorder(),
          constraints: BoxConstraints.tightFor(width: 65, height: 65),
          child: Icon(Icons.add, size: 40),
        ),
      ),
    );
  }
}
