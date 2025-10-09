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
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: reviews.isEmpty
                      ? Center(child: Text("No reviews"))
                      : ListView.builder(
                          itemCount: reviews.length,
                          itemBuilder: (context, index) {
                            final review = reviews[index];
                            return buildReviewCard(review);
                          },
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
      padding: EdgeInsets.all(10),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(review['image'], width: 150, height: 150, fit: BoxFit.cover),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(radius: 15.0, backgroundImage: AssetImage(DEFAULT_PROFILE_IMG)),
                        Text("${review['username']}"),
                      ],
                    ),
                    Text(getTimeSinceShort(review['createdAt'].toDate())),
                    Text("${review['name']}"),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber),
                        Icon(Icons.star, color: Colors.amber),
                        Icon(Icons.star, color: Colors.amber),
                        Icon(Icons.star, color: Colors.amber),
                        Icon(Icons.star, color: Colors.amber),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          Text("${review['content']}", textAlign: TextAlign.left),
          Row(children: [Icon(Icons.favorite), Icon(Icons.comment)]),
        ],
      ),
    );
  }
}
