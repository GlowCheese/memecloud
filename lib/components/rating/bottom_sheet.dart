import 'package:flutter/material.dart';
import 'package:memecloud/pages/report/report_issue_page.dart';
import 'package:memecloud/components/rating/rating_dialog.dart';

Future showRatingBottomSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.star_rate, color: Colors.amber),
              title: const Text('Đánh giá'),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) => const RatingDialog(),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.report_problem, color: Colors.red),
              title: const Text('Báo lỗi'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ReportIssuePage(),
                  ),
                );
              },
            ),
          ],
        ),
      );
    },
  );
}
