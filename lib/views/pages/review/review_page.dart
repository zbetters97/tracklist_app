import 'package:flutter/material.dart';
import 'package:tracklist_app/data/classes/review_class.dart';
import 'package:tracklist_app/data/constants.dart';
import 'package:tracklist_app/views/pages/profile/user_page.dart';
import 'package:tracklist_app/views/widgets/my_app_bar.dart';
import 'package:tracklist_app/views/widgets/review_card_widget.dart';

class ReviewPage extends StatefulWidget {
  const ReviewPage({super.key, required this.review});

  final Review review;

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: "Review"),
      backgroundColor: BACKGROUND_COLOR,
      body: GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => UserPage(uid: widget.review.uid)));
        },
        child: ReviewCardWidget(review: widget.review),
      ),
    );
  }
}
