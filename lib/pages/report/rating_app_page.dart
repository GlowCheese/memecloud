import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class RatingPopupDemo extends StatefulWidget {
  const RatingPopupDemo({super.key});

  @override
  State<RatingPopupDemo> createState() => _RatingPopupDemoState();
}

class _RatingPopupDemoState extends State<RatingPopupDemo> {
  double musicRating = 0;
  double uiRating = 0;
  double uxRating = 0;

  void showRatingDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Đánh giá ứng dụng'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildRatingRow("Âm nhạc", (rating) {
                setState(() {
                  musicRating = rating;
                });
              }),
              buildRatingRow("Giao diện", (rating) {
                setState(() {
                  uiRating = rating;
                });
              }),
              buildRatingRow("Trải nghiệm", (rating) {
                setState(() {
                  uxRating = rating;
                });
              }),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Bạn có thể xử lý lưu đánh giá ở đây
                print("Âm nhạc: $musicRating");
                print("Giao diện: $uiRating");
                print("Trải nghiệm: $uxRating");
                Navigator.of(context).pop();
              },
              child: Text('Gửi'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Hủy'),
            ),
          ],
        );
      },
    );
  }

  Widget buildRatingRow(String title, Function(double) onRatingUpdate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title),
        RatingBar.builder(
          initialRating: 0,
          minRating: 0,
          direction: Axis.horizontal,
          allowHalfRating: false,
          itemCount: 5,
          itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
          itemBuilder: (context, _) => Icon(Icons.star, color: Colors.amber),
          onRatingUpdate: onRatingUpdate,
        ),
        SizedBox(height: 10),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("App Nghe Nhạc"),
        actions: [
          IconButton(
            icon: Icon(Icons.flag),
            onPressed: showRatingDialog,
          ),
        ],
      ),
      body: Center(
        child: Text("Nội dung app nghe nhạc ở đây"),
      ),
    );
  }
}
