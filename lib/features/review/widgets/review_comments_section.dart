import 'package:flutter/material.dart';
import 'package:tracklist_app/core/constants/constants.dart';
import 'package:tracklist_app/data/models/comment_class.dart';
import 'package:tracklist_app/data/models/review_class.dart';
import 'package:tracklist_app/data/sources/auth_service.dart';
import 'package:tracklist_app/data/sources/comment_service.dart';
import 'package:tracklist_app/features/comment/widgets/comment_card_widget.dart';

class ReviewCommentsSection extends StatefulWidget {
  const ReviewCommentsSection({super.key, required this.review});

  final Review review;

  @override
  State<ReviewCommentsSection> createState() => _ReviewCommentsSectionState();
}

class _ReviewCommentsSectionState extends State<ReviewCommentsSection> {
  Review get review => widget.review;

  TextEditingController commentController = TextEditingController();

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

    for (String commentId in review.comments) {
      Comment comment = await getCommentById(commentId);
      comments.add(comment);
    }

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

  void postComment(String content) async {
    Comment newComment = await addComment(content, authUser.value!.uid, review.reviewId);

    FocusManager.instance.primaryFocus?.unfocus();
    commentController.clear();

    setState(() {
      comments.insert(0, newComment);
      sortComments();
    });
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

    if (!confirm!) return;

    await deleteComment(commentId);
    setState(() => comments.removeWhere((comment) => comment.commentId == commentId));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: TERTIARY_COLOR),
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator(color: PRIMARY_COLOR_DARK))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildCommentsHeader(),
                  const SizedBox(height: 8.0),
                  buildCommentFilters(),
                  const SizedBox(height: 24.0),
                  buildPostCommentWidget(),
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

  Widget buildPostCommentWidget() {
    String profileUrl = authUser.value?.profileUrl ?? "";
    CircleAvatar profileImage = profileUrl.startsWith("https")
        ? CircleAvatar(radius: 20.0, backgroundImage: NetworkImage(profileUrl))
        : CircleAvatar(radius: 20.0, backgroundImage: AssetImage(DEFAULT_PROFILE_IMG));

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 8.0,
      children: [
        profileImage,
        Expanded(
          child: TextField(
            controller: commentController,
            style: TextStyle(fontSize: 20),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
            ),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: Size(0.0, 40.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            backgroundColor: PRIMARY_COLOR_DARK,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
          ),
          onPressed: () {
            if (commentController.text.isEmpty) return;
            if (commentController.text.trim().isEmpty) return;
            postComment(commentController.text);
          },
          child: Text("Post", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        ),
      ],
    );
  }

  Widget buildCommentsList() {
    return Column(
      spacing: 12.0,
      children: comments
          .map(
            (comment) =>
                CommentCardWidget(key: ValueKey(comment.commentId), comment: comment, onDeleteComment: removeComment),
          )
          .toList(),
    );
  }
}
