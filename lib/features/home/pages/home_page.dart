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
  int _currentTab = 0;
  bool _isLoading = true;

  bool _isLoadingNew = false;
  bool _isLoadingPopular = false;

  DocumentSnapshot? _lastNewReviewDoc;
  DocumentSnapshot? _lastPopularReviewDoc;

  final ScrollController __newReviewsController = ScrollController();
  final ScrollController __popularReviewsController = ScrollController();

  List<Review> _newReviews = [];
  List<Review> _popularReviews = [];

  @override
  void initState() {
    super.initState();
    _attachListeners();
    _getReviews();
  }

  @override
  void dispose() {
    __newReviewsController.dispose();
    __popularReviewsController.dispose();
    super.dispose();
  }

  void _attachListeners() {
    __newReviewsController.addListener(() {
      if (__newReviewsController.position.pixels >= __newReviewsController.position.maxScrollExtent - 200 &&
          !_isLoadingNew) {
        _loadMoreNewReviews();
      }
    });

    __popularReviewsController.addListener(() {
      if (__popularReviewsController.position.pixels >= __popularReviewsController.position.maxScrollExtent - 200 &&
          !_isLoadingPopular) {
        _loadMorePopularReviews();
      }
    });
  }

  void _getReviews() async {
    if (_newReviews.isNotEmpty && _popularReviews.isNotEmpty) return;

    setState(() => _isLoading = true);

    final List<List<Review>> fetchedReviews = await Future.wait([getFollowingReviews(), getPopularReviews()]);

    // Avoids memory leaks
    if (!mounted) return;

    _newReviews = fetchedReviews[0];
    _popularReviews = fetchedReviews[1];

    _lastNewReviewDoc = _newReviews.isNotEmpty ? _newReviews.last.doc : null;
    _lastPopularReviewDoc = _popularReviews.isNotEmpty ? _popularReviews.last.doc : null;

    setState(() => _isLoading = false);
  }

  void _setReviews(int tabIndex) {
    if (_currentTab == tabIndex) return;

    setState(() => _currentTab = tabIndex);
  }

  Future<void> _loadMoreNewReviews() async {
    if (_newReviews.isEmpty || _isLoadingNew) return;

    setState(() => _isLoadingNew = true);

    final List<Review> moreNewReviews = await getFollowingReviews(lastDoc: _lastNewReviewDoc);

    if (moreNewReviews.isNotEmpty) {
      setState(() {
        _lastNewReviewDoc = moreNewReviews.last.doc;
        _newReviews.addAll(moreNewReviews);
      });
    }

    setState(() => _isLoadingNew = false);
  }

  Future<void> _loadMorePopularReviews() async {
    if (_popularReviews.isEmpty || _isLoadingPopular) return;

    setState(() => _isLoadingPopular = true);

    final List<Review> morePopularReviews = await getPopularReviews(lastDoc: _lastPopularReviewDoc);

    if (morePopularReviews.isNotEmpty) {
      setState(() {
        _lastPopularReviewDoc = morePopularReviews.last.doc;
        _popularReviews.addAll(morePopularReviews);
      });
    }

    setState(() => _isLoadingPopular = false);
  }

  Future<void> _refreshReviews() async {
    _newReviews.clear();
    _popularReviews.clear();

    setState(() {
      _isLoadingNew = false;
      _isLoadingPopular = false;

      _lastNewReviewDoc = null;
      _lastPopularReviewDoc = null;
    });

    _getReviews();
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
      _refreshReviews();
    }
  }

  void _sendToAddReviewPage() {
    NavigationService().openAddReview();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(children: [_buildHero(), _buildTopBar(), _buildReviews()]),
        _buildPostReviewButton(),
      ],
    );
  }

  Widget _buildHero() {
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

  Widget _buildTopBar() {
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
        children: [_buildHomeTab(0, "Newest"), SizedBox(width: 30), _buildHomeTab(1, "For You")],
      ),
    );
  }

  Widget _buildHomeTab(int index, String title) {
    return GestureDetector(
      onTap: () => _setReviews(index),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: _currentTab == index ? PRIMARY_COLOR : Colors.grey,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Container(
            height: 5,
            width: 100,
            decoration: BoxDecoration(
              color: _currentTab == index ? PRIMARY_COLOR : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviews() {
    if (_isLoading) {
      return const Expanded(child: LoadingIcon());
    }

    return Expanded(
      child: IndexedStack(
        index: _currentTab,
        children: [
          _newReviews.isEmpty
              ? EmptyText(message: "No reviews found!")
              : _buildReviewsList(_newReviews, _isLoadingNew, __newReviewsController),
          _popularReviews.isEmpty
              ? EmptyText(message: "No reviews found!")
              : _buildReviewsList(_popularReviews, _isLoadingPopular, __popularReviewsController),
        ],
      ),
    );
  }

  Widget _buildReviewsList(List<Review> reviews, bool isLoadingMore, ScrollController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: RefreshIndicator.adaptive(
        onRefresh: () async => _refreshReviews(),
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
              onOpenReview: () => _onOpenReview(reviews[index].reviewId),
              onDeleteReview: () => _onDeleteReview(reviews[index].reviewId),
            );
          },
          separatorBuilder: (context, index) => const Divider(color: Colors.grey),
        ),
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
