import 'dart:ui';

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
  int currentTab = 0;
  bool isLoading = true;
  List<Map<String, dynamic>> reviews = [];

  void getReviews() async {
    final List<Map<String, dynamic>> fetchedReviews = await getPopularReviews();

    setState(() {
      isLoading = false;
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
    return Stack(
      children: [
        Column(
          children: [
            TopBar(),
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator(color: PRIMARY_COLOR_DARK))
                  : reviews.isEmpty
                  ? Center(
                      child: Text(
                        "No reviews found!",
                        style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic, fontSize: 24),
                      ),
                    )
                  : ReviewCardsList(),
            ),
          ],
        ),
        PostReviewButton(),
      ],
    );
  }

  Widget TopBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: BACKGROUND_COLOR,
        boxShadow: [
          BoxShadow(color: const Color.fromRGBO(0, 0, 0, 0.3), blurRadius: 3, offset: Offset(0, 6), spreadRadius: 2),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => setState(() => currentTab = 0),
            child: Column(
              children: [
                Text(
                  "Newest",
                  style: TextStyle(
                    color: currentTab == 0 ? PRIMARY_COLOR : Colors.grey,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Container(
                  height: 5,
                  width: 100,
                  decoration: BoxDecoration(
                    color: currentTab == 0 ? PRIMARY_COLOR : Colors.transparent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 30),
          GestureDetector(
            onTap: () => setState(() => currentTab = 1),
            child: Column(
              children: [
                Text(
                  "For You",
                  style: TextStyle(
                    color: currentTab == 1 ? PRIMARY_COLOR : Colors.grey,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Container(
                  height: 5,
                  width: 100,
                  decoration: BoxDecoration(
                    color: currentTab == 1 ? PRIMARY_COLOR : Colors.transparent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget ReviewCardsList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: ListView.separated(
        itemCount: reviews.length,
        itemBuilder: (context, index) {
          final review = reviews[index];
          return buildReviewCard(review);
        },
        separatorBuilder: (context, index) => Divider(color: Colors.grey),
      ),
    );
  }

  Widget buildReviewCard(Map<String, dynamic> review) {
    return Container(
      padding: EdgeInsets.only(top: 10, bottom: 10, left: 5, right: 5),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                MediaImage(review['image']),
                SizedBox(width: 10),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      UserInfo(review['username']),
                      ReviewDate(review['createdAt'].toDate()),
                      MediaName(review['name']),
                      Stars(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          ReviewContent(review['content']),
          SizedBox(height: 10),
          ReviewButtons(),
        ],
      ),
    );
  }

  Widget MediaImage(String imageUrl) {
    return Image.network(imageUrl, width: 125, height: 125, fit: BoxFit.cover);
  }

  Widget UserInfo(String username) {
    return Row(
      children: [
        CircleAvatar(radius: 12.0, backgroundImage: AssetImage(DEFAULT_PROFILE_IMG)),
        SizedBox(width: 5),
        Text("@${username}", style: TextStyle(color: Colors.grey, fontSize: 16)),
      ],
    );
  }

  Widget ReviewDate(DateTime date) {
    return Text(
      getTimeSinceShort(date),
      style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 16, overflow: TextOverflow.ellipsis),
    );
  }

  Widget MediaName(String name) {
    // Icon, Media Name
    return Row(
      children: [
        Icon(Icons.music_note, color: Colors.grey, size: 24),
        Flexible(
          child: Text(
            name,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
      ],
    );
  }

  Widget ReviewContent(String content) {
    return Text(
      content,
      textAlign: TextAlign.left,
      style: TextStyle(color: Colors.white, fontSize: 20),
      overflow: TextOverflow.ellipsis,
      maxLines: 4,
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

  Widget ReviewButtons() {
    return Row(
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
    );
  }

  Widget PostReviewButton() {
    return Align(
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
    );
  }
}
