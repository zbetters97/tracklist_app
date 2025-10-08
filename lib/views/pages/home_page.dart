import 'package:flutter/material.dart';
import 'package:tracklist_app/data/constants.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void fetchArtist() async {}

  List<Map<String, dynamic>> reviews = [
    {"id": 1, "name": "@JohnDoe", "rating": 4.5, "date": "2023-01-01", "comment": "Great album! I loved it."},
    {"id": 2, "name": "@JaneDoe", "rating": 4.0, "date": "2023-02-01", "comment": "Good album, but could be better."},
  ];

  @override
  Widget build(BuildContext context) {
    fetchArtist();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          Expanded(
            child: Column(
              // Your main content
              children: [
                Expanded(
                  child: reviews.isEmpty
                      ? Center(child: Text("No reviews"))
                      : ListView.builder(
                          itemCount: reviews.length,
                          itemBuilder: (context, index) {
                            final review = reviews[index];

                            return Container(
                              width: double.infinity,
                              padding: EdgeInsets.only(top: 2.0),
                              child: Card(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [Text(review["name"]), Text(review["comment"]), Text(review["date"])],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: RawMaterialButton(
                onPressed: () {},
                fillColor: PRIMARY_COLOR,
                shape: CircleBorder(),
                constraints: BoxConstraints.tightFor(width: 70, height: 70),
                child: Icon(Icons.add, size: 50),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
