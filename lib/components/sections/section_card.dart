import 'package:flutter/material.dart';
import 'package:memecloud/components/miscs/grad_background.dart';
import 'package:memecloud/pages/ssp/simple_scrollable_page.dart';

class SectionCard {
  final Key? key;
  final String title;

  SectionCard({this.key, required this.title});

  Widget variant1({
    EdgeInsetsGeometry? titlePadding,
    required Widget child,
    Widget? showAllButton,
  }) {
    final titleRow = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        if (showAllButton != null) showAllButton,
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (titlePadding == null)
          titleRow
        else
          Padding(padding: titlePadding, child: titleRow),
        child,
      ],
    );
  }

  Widget variant2({
    EdgeInsetsGeometry? titlePadding,
    required Widget child,
    required Widget Function(BuildContext context) showAllBuilder,
  }) {
    return variant1(
      titlePadding: titlePadding,
      child: child,
      showAllButton: Builder(
        builder: (context) {
          return TextButton(
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: showAllBuilder));
            },
            child: const Text('Xem tất cả'),
          );
        },
      ),
    );
  }

  // Widget variant3({
  //   EdgeInsetsGeometry? titlePadding,
  // })
}
