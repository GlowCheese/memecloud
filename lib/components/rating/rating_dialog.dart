import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:memecloud/core/getit.dart';

class RatingDialog extends StatefulWidget {
  const RatingDialog({super.key});

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  double musicRating = 0;
  double uiRating = 0;
  double uxRating = 0;

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
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Hủy'),
        ),
        _sendButton(context, musicRating, uiRating, uxRating),
      ],
    );
  }
}

Widget _sendButton(
  BuildContext context,
  double musicRating,
  double uiRating,
  double uxRating,
) {
  return OutlinedButton.icon(
    onPressed: () {
      if (musicRating > 0 && uiRating > 0 && uxRating > 0) {
        unawaited(
          getIt<ApiKit>().supabase.ratingApi.sendRatings(
            musicRating: musicRating,
            uiRating: uiRating,
            uxRating: uxRating,
          ),
        );
        Navigator.of(context).pop();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Cảm ơn đã đánh giá')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Vui lòng đánh giá đầy đủ cả Âm nhạc, Giao diện và Trải nghiệm trước khi gửi.',
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    },
    label: Text('Gửi'),
    icon: Icon(Icons.send),
    style: OutlinedButton.styleFrom(
      foregroundColor:
          (musicRating > 0 && uiRating > 0 && uxRating > 0)
              ? null
              : Colors.grey,
    ),
  );
}
