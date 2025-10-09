import 'package:flutter/material.dart';
import 'package:tracklist_app/data/constants.dart';
import 'package:tracklist_app/date.dart';
import 'package:tracklist_app/services/review_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> reviews = [];

  void getReviews() async {
    final List<Map<String, dynamic>> fetchedReviews = await getPopularReviews();

    setState(() {
      reviews = fetchedReviews;
    });
  }

  @override
  void initState() {
    super.initState();
    getReviews();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Stack(
        children: [
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: reviews.isEmpty
                      ? Center(child: Text("No reviews"))
                      : ListView.separated(
                          itemCount: reviews.length,
                          itemBuilder: (context, index) {
                            final review = reviews[index];
                            return buildReviewCard(review);
                          },
                          separatorBuilder: (context, index) => Divider(color: Colors.grey),
                        ),
                ),
              ],
            ),
          ),
          Align(
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
          ),
        ],
      ),
    );
  }

  Widget buildReviewCard(Map<String, dynamic> review) {
    return Container(
      padding: EdgeInsets.only(top: 10, bottom: 10, left: 5, right: 5),
      width: double.infinity,
      // Header, Body, Footer
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image, Details
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.network(review['image'], width: 125, height: 125, fit: BoxFit.cover, scale: 1 / 1),
                SizedBox(width: 10),
                Expanded(
                  // Profile, Date, Name, Rating
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Avatar, Username
                      Row(
                        children: [
                          CircleAvatar(radius: 12.0, backgroundImage: AssetImage(DEFAULT_PROFILE_IMG)),
                          SizedBox(width: 5),
                          Text("@${review['username']}", style: TextStyle(color: Colors.grey, fontSize: 16)),
                        ],
                      ),
                      Text(
                        getTimeSinceShort(review['createdAt'].toDate()),
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Icon, Media Name
                      Row(
                        children: [
                          Icon(Icons.music_note, color: Colors.grey, size: 24),
                          Text(
                            "${review['name']}",
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                        ],
                      ),
                      Stars(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Text(
            "${review['content']}",
            textAlign: TextAlign.left,
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          SizedBox(height: 10),
          // Like, Comment
          Row(
            children: [
              Icon(Icons.favorite, size: 30),
              SizedBox(width: 5),
              Text("3", style: TextStyle(color: Colors.white, fontSize: 24)),
              SizedBox(width: 20),
              Icon(Icons.comment, size: 30),
              SizedBox(width: 5),
              Text("1", style: TextStyle(color: Colors.white, fontSize: 24)),
              SizedBox(width: 20),
              Icon(Icons.delete, size: 30),
            ],
          ),
        ],
      ),
    );
  }

  Widget Stars() {
    return Row(
      children: [
        Icon(Icons.star, color: Colors.amber),
        Icon(Icons.star, color: Colors.amber),
        Icon(Icons.star, color: Colors.amber),
        Icon(Icons.star, color: Colors.amber),
        Icon(Icons.star, color: Colors.amber),
      ],
    );
  }
}
