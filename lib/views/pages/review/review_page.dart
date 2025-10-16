import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:tracklist_app/data/classes/review_class.dart';
import 'package:tracklist_app/data/constants.dart';
import 'package:tracklist_app/data/utils/date.dart';
import 'package:tracklist_app/views/pages/profile/user_page.dart';
import 'package:tracklist_app/views/widgets/my_app_bar.dart';

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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              buildMediaBanner(widget.review.media.image, widget.review.category, widget.review.media.name),
              const SizedBox(height: 24),
              buildReviewHeader(widget.review.username, widget.review.createdAt.toDate(), widget.review.rating),
              const SizedBox(height: 12),
              buildReviewContent(widget.review.content),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildMediaBanner(String image, String category, String name) {
    Icon mediaIcon = category == "artist"
        ? Icon(Icons.person, color: Colors.grey, size: 28)
        : category == "album"
        ? Icon(Icons.album, color: Colors.grey, size: 28)
        : Icon(Icons.music_note, color: Colors.grey, size: 28);

    return Column(
      children: [
        Image.network(image, width: 275, height: 275, fit: BoxFit.cover),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            mediaIcon,
            SizedBox(width: 5),
            Flexible(
              child: Text(
                name,
                style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildReviewHeader(String username, DateTime date, double rating) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(radius: 30.0, backgroundImage: AssetImage(DEFAULT_PROFILE_IMG)),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  style: TextStyle(color: Colors.grey, fontSize: 18),
                  children: [
                    TextSpan(text: "Review by "),
                    TextSpan(
                      text: username,
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => UserPage(uid: widget.review.uid)),
                          );
                        },
                    ),
                  ],
                ),
              ),
              Text(formatDateMDY(date), style: TextStyle(color: Colors.grey, fontSize: 18)),
              buildReviewStars(rating),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildReviewStars(double rating) {
    Color getStarColor(double ratingValue) {
      return ratingValue <= rating ? Colors.amber : Colors.grey;
    }

    return Row(
      children: List.generate(5, (i) {
        double ratingValue = i + 1;
        bool isHalf = rating == ratingValue - 0.5;

        return Icon(
          isHalf ? Icons.star_half : Icons.star,
          color: isHalf ? Colors.amber : getStarColor(ratingValue),
          size: 30,
        );
      }),
    );
  }

  Widget buildReviewContent(String content) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(content, style: TextStyle(color: Colors.white, fontSize: 20)),
    );
  }
}
