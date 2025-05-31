import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:memecloud/core/getit.dart';

class RatingPage extends StatefulWidget {
  const RatingPage({super.key});

  @override
  State<RatingPage> createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> {
  final _formKey = GlobalKey<FormState>();
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
                if (!_formKey.currentState!.validate()) return;
                unawaited(
                  getIt<ApiKit>().supabase.ratingApi.sendRatings(
                    musicRating: musicRating,
                    uiRating: uiRating,
                    uxRating: uxRating,
                  ),
                );
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
          IconButton(icon: Icon(Icons.flag), onPressed: showRatingDialog),
        ],
      ),
      body: Center(child: Text("Nội dung app nghe nhạc ở đây")),
    );
  }
}
