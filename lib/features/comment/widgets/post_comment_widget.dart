import 'package:flutter/material.dart';
import 'package:tracklist_app/core/constants/constants.dart';
import 'package:tracklist_app/core/utils/notifiers.dart';

class PostCommentWidget extends StatefulWidget {
  final String reviewId;
  final String replyingToId;
  final Function(String content, String replyingToId) onPostComment;

  const PostCommentWidget({super.key, required this.reviewId, this.replyingToId = "", required this.onPostComment});

  @override
  State<PostCommentWidget> createState() => _PostCommentWidgetState();
}

class _PostCommentWidgetState extends State<PostCommentWidget> {
  TextEditingController commentController = TextEditingController();

  void onPostPressed() {
    if (commentController.text.isEmpty) return;
    if (commentController.text.trim().isEmpty) return;

    widget.onPostComment(commentController.text, widget.replyingToId);
    commentController.clear();
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String profileUrl = authUser.value?.profileUrl ?? "";
    CircleAvatar profileImage = profileUrl.startsWith("https")
        ? CircleAvatar(radius: 20.0, backgroundImage: NetworkImage(profileUrl))
        : CircleAvatar(radius: 20.0, backgroundImage: AssetImage(DEFAULT_PROFILE_IMG));

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 8.0,
      children: [profileImage, buildTextField(), buildPostButton()],
    );
  }

  Widget buildTextField() {
    return Expanded(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: 40),
        child: TextField(
          controller: commentController,
          style: TextStyle(fontSize: 16),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 8),
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
            hintText: widget.replyingToId != "" ? "Add a reply..." : "Add a comment...",
          ),
        ),
      ),
    );
  }

  Widget buildPostButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: Size(0.0, 40.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        backgroundColor: PRIMARY_COLOR_DARK,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
      onPressed: () => onPostPressed(),
      child: Text("Post", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
    );
  }
}
