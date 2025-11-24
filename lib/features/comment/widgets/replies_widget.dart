import 'package:flutter/material.dart';
import 'package:tracklist_app/core/constants/constants.dart';
import 'package:tracklist_app/features/comment/models/comment_class.dart';
import 'package:tracklist_app/features/comment/services/comment_service.dart';
import 'package:tracklist_app/features/comment/widgets/comment_card_widget.dart';

class RepliesWidget extends StatefulWidget {
  final Comment comment;
  final String reviewId;
  final void Function(String content, String replyingToId) onPostComment;
  final void Function(String commentId) onDeleteComment;

  const RepliesWidget({
    super.key,
    required this.comment,
    required this.reviewId,
    required this.onPostComment,
    required this.onDeleteComment,
  });

  @override
  State<RepliesWidget> createState() => _RepliesWidgetState();
}

class _RepliesWidgetState extends State<RepliesWidget> {
  late List<Comment> replies = [];

  bool _isRepliesExpanded = false;

  @override
  void initState() {
    super.initState();
    _fetchReplies();
  }

  @override
  void dispose() {
    replies.clear();
    _isRepliesExpanded = false;
    super.dispose();
  }

  void _fetchReplies() async {
    List<Comment> fetchedReplies = await getRepliesByComment(widget.comment);

    if (!mounted) return;

    setState(() => replies = fetchedReplies);
  }

  @override
  Widget build(BuildContext context) {
    if (replies.isEmpty) {
      return Container();
    }

    if (!_isRepliesExpanded) {
      return _buildExpandRepliesButton();
    }

    return Column(spacing: 12.0, children: [_buildExpandRepliesButton(), _buildReplies()]);
  }

  Widget _buildExpandRepliesButton() {
    String repliesWord = replies.length == 1 ? "reply" : "replies";
    IconData arrowIcon = _isRepliesExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down;

    return GestureDetector(
      onTap: () => setState(() => _isRepliesExpanded = !_isRepliesExpanded),
      child: Row(
        children: [
          Icon(arrowIcon, size: 24, color: PRIMARY_BLUE),
          Text.rich(
            TextSpan(
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: PRIMARY_BLUE),
              children: [
                TextSpan(text: replies.length.toString()),
                TextSpan(text: " $repliesWord"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReplies() {
    return Column(
      children: [
        ...replies.map(
          (reply) => Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: CommentCardWidget(
              key: ValueKey(reply.commentId),
              comment: reply,
              reviewId: widget.reviewId,
              onPostComment: widget.onPostComment,
              onDeleteComment: widget.onDeleteComment,
            ),
          ),
        ),
      ],
    );
  }
}
