import 'package:flutter/material.dart';
import 'package:tracklist_app/core/constants/constants.dart';
import 'package:tracklist_app/core/utils/notifiers.dart';
import 'package:tracklist_app/core/widgets/empty_text.dart';
import 'package:tracklist_app/core/widgets/loading_icon.dart';
import 'package:tracklist_app/features/comment/models/comment_class.dart';
import 'package:tracklist_app/features/review/models/review_class.dart';
import 'package:tracklist_app/features/comment/services/comment_service.dart';
import 'package:tracklist_app/features/comment/widgets/comment_card_widget.dart';
import 'package:tracklist_app/features/comment/widgets/post_comment_widget.dart';
import 'package:tracklist_app/features/review/pages/review_page.dart';

class ReviewCommentsContent extends StatefulWidget {
  final Review review;

  const ReviewCommentsContent({super.key, required this.review});

  @override
  State<ReviewCommentsContent> createState() => _ReviewCommentsContentState();
}

class _ReviewCommentsContentState extends State<ReviewCommentsContent> {
  Review get review => widget.review;

  final List<String> commentFilters = ["Newest", "Oldest", "Best", "Worst"];
  int selectedFilter = 0;

  late List<Comment> comments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchComments();
  }

  void fetchComments() async {
    setState(() => isLoading = true);

    // Fetch comments
    comments = await getCommentsByReviewId(review);

    // Avoid memory leak
    if (!mounted) return;

    setState(() {
      sortComments();
      isLoading = false;
    });
  }

  void sortComments() {
    if (selectedFilter == 0) comments.sort(Comment.compareByNewest);
    if (selectedFilter == 1) comments.sort(Comment.compareByOldest);
    if (selectedFilter == 2) comments.sort(Comment.compareByLikes);
    if (selectedFilter == 3) comments.sort(Comment.compareByDislikes);
  }

  void postComment(String content, String replyingToId) async {
    await addComment(content, authUser.value!.uid, review.reviewId, replyingToId: replyingToId);

    FocusManager.instance.primaryFocus?.unfocus();

    // Avoid memory leak
    if (!mounted) return;

    // TODO: Implement cleaner way of updating comments without refreshing
    // Refresh entire page to update comments
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (context) => ReviewPage(reviewId: review.reviewId)));
  }

  void removeComment(String commentId) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Comment"),
        content: const Text("Are you sure you want to delete this comment?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete")),
        ],
      ),
    );

    if (!confirm! || !mounted) return;

    await deleteComment(commentId);
    setState(() => comments.removeWhere((comment) => comment.commentId == commentId));
  }

  @override
  void dispose() {
    comments.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: TERTIARY_COLOR),
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: isLoading
            ? LoadingIcon()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildCommentsHeader(),
                  const SizedBox(height: 8.0),
                  buildCommentFilters(),
                  const SizedBox(height: 24.0),
                  PostCommentWidget(reviewId: review.reviewId, onPostComment: postComment),
                  const SizedBox(height: 24.0),
                  buildCommentsList(),
                ],
              ),
      ),
    );
  }

  Widget buildCommentsHeader() {
    return Text(
      "${comments.length} Comments",
      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget buildCommentFilters() {
    return ToggleButtons(
      isSelected: List.generate(commentFilters.length, (index) => index == selectedFilter),
      onPressed: (index) => setState(() {
        selectedFilter = index;
        sortComments();
      }),
      color: Colors.white,
      selectedColor: Colors.black,
      selectedBorderColor: Colors.white,
      fillColor: Colors.white,
      borderColor: Colors.grey,
      constraints: BoxConstraints(minHeight: 40),
      borderRadius: BorderRadius.circular(8),
      children: commentFilters.map((label) {
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        );
      }).toList(),
    );
  }

  Widget buildCommentsList() {
    if (comments.isEmpty) {
      return EmptyText(message: "No comments yet!");
    }

    return Column(
      spacing: 12.0,
      children: comments
          .where((comment) => comment.replyingTo == "") // Only show top-level comments
          .map(
            (comment) => CommentCardWidget(
              key: ValueKey(comment.commentId),
              comment: comment,
              reviewId: review.reviewId,
              onPostComment: postComment,
              onDeleteComment: removeComment,
            ),
          )
          .toList(),
    );
  }
}
