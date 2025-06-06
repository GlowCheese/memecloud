import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:memecloud/pages/report/report_issue_page.dart';
import 'package:memecloud/components/rating/rating_dialog.dart';
import 'package:memecloud/utils/images.dart';

AppBar defaultAppBar(
  BuildContext context, {
  required String title,
  Object iconUri = 'assets/icons/listen.png',
}) {
  late final Widget icon;

  if (iconUri is String) {
    icon = Image.asset(iconUri, width: 30, height: 30);
  } else if (iconUri is IconData) {
    icon = Icon(iconUri, size: 30);
  } else {
    throw UnsupportedError(
      "Unsupported iconUri=$iconUri of type ${iconUri.runtimeType}",
    );
  }

  return AppBar(
    backgroundColor: Colors.transparent,
    title: Text(
      title,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
    ),
    leadingWidth: 60,
    leading: Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.only(left: 30),
      child: icon,
    ),
    actions: [
      IconButton(
        onPressed: () {
          _showBottomSheet(context);
        },
        icon: const Icon(Icons.flag, color: Colors.white),
      ),
      IconButton(
        color: Colors.white,
        onPressed: () {},
        icon: const Icon(Icons.notifications),
      ),
      const SizedBox(width: 8),
      GestureDetector(
        onTap: () => context.push('/profile'),
        child: CircleAvatar(
          backgroundImage: getImageProvider(
            getIt<ApiKit>().myProfile().avatarUrl,
          ),
        ),
      ),
      const SizedBox(width: 20),
    ],
  );
}

void _showBottomSheet(BuildContext context) {
  showModalBottomSheet(
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
