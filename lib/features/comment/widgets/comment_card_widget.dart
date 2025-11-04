import 'package:flutter/material.dart';
import 'package:tracklist_app/core/constants/constants.dart';
import 'package:tracklist_app/core/utils/date.dart';
import 'package:tracklist_app/features/comment/models/comment_class.dart';
import 'package:tracklist_app/features/auth/services/auth_service.dart';
import 'package:tracklist_app/features/comment/services/comment_service.dart';
import 'package:tracklist_app/features/comment/widgets/post_comment_widget.dart';
import 'package:tracklist_app/features/comment/widgets/replies_widget.dart';
import 'package:tracklist_app/features/user/pages/user_page.dart';

class CommentCardWidget extends StatefulWidget {
  const CommentCardWidget({
    super.key,
    required this.comment,
    required this.reviewId,
    required this.onPostComment,
    required this.onDeleteComment,
  });

  final Comment comment;
  final String reviewId;
  final void Function(String content, String replyingToId) onPostComment;
  final void Function(String commentId) onDeleteComment;

  @override
  State<CommentCardWidget> createState() => _CommentCardWidgetState();
}

class _CommentCardWidgetState extends State<CommentCardWidget> {
  late Comment comment;

  bool isReplying = false;

  @override
  void initState() {
    super.initState();
    comment = widget.comment;
  }

  void sendToUserPage(BuildContext context, String userId) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => UserPage(uid: userId)));
  }

  @override
  void dispose() {
    isReplying = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    CircleAvatar profileImage = comment.user.profileUrl.startsWith("https")
        ? CircleAvatar(radius: 20.0, backgroundImage: NetworkImage(comment.user.profileUrl))
        : CircleAvatar(radius: 20.0, backgroundImage: AssetImage(DEFAULT_PROFILE_IMG));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 4.0,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => sendToUserPage(context, comment.user.uid),
              child: Row(
                children: [
                  profileImage,
                  const SizedBox(width: 2.0),
                  Text(
                    "@${comment.user.username}",
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8.0),
            Text(getTimeSinceShort(comment.createdAt), style: TextStyle(color: Colors.grey)),
          ],
        ),
        Text(comment.content, style: TextStyle(color: Colors.white, fontSize: 16.0)),
        buildCommentButtons(),
        if (isReplying)
          PostCommentWidget(
            reviewId: widget.reviewId,
            replyingToId: comment.commentId,
            onPostComment: widget.onPostComment,
          ),
        RepliesWidget(
          comment: comment,
          reviewId: widget.reviewId,
          onPostComment: widget.onPostComment,
          onDeleteComment: widget.onDeleteComment,
        ),
      ],
    );
  }

  Widget buildCommentButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      spacing: 12.0,
      children: [buildLikeButton(), buildDislikeButton(), buildReplyButton(), buildDeleteButton()],
    );
  }

  Widget buildLikeButton() {
    bool isLiked = comment.likes.contains(authUser.value!.uid);

    return GestureDetector(
      onTap: () async {
        setState(() => isLiked ? comment.likes.remove(authUser.value!.uid) : comment.likes.add(authUser.value!.uid));
        await likeComment(comment.commentId, authUser.value!.uid);
      },
      child: Row(
        spacing: 4.0,
        children: [
          Icon(Icons.thumb_up, size: 20, color: isLiked ? PRIMARY_COLOR_LIGHT : Colors.white),
          Text(
            comment.likes.length.toString(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isLiked ? PRIMARY_COLOR_LIGHT : Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDislikeButton() {
    bool isDisliked = comment.dislikes.contains(authUser.value!.uid);

    return GestureDetector(
      onTap: () async {
        setState(() {
          isDisliked ? comment.dislikes.remove(authUser.value!.uid) : comment.dislikes.add(authUser.value!.uid);
        });
        await dislikeComment(comment.commentId, authUser.value!.uid);
      },
      child: Row(
        spacing: 4.0,
        children: [
          Icon(Icons.thumb_down, size: 20, color: isDisliked ? Colors.red : Colors.white),
          Text(
            comment.dislikes.length.toString(),
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDisliked ? Colors.red : Colors.white),
          ),
        ],
      ),
    );
  }

  Widget buildReplyButton() {
    return GestureDetector(
      onTap: () => setState(() => isReplying = !isReplying),
      child: Text("Reply", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }

  Widget buildDeleteButton() {
    if (authUser.value?.uid == comment.user.uid) {
      return GestureDetector(
        onTap: () => widget.onDeleteComment(comment.commentId),
        child: Icon(Icons.delete, size: 20),
      );
    }

    return Container();
  }
}
