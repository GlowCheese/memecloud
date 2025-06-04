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
      key: key,
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

  Widget variant3({
    EdgeInsetsGeometry? titlePadding,
    EdgeInsetsGeometry listViewPadding = const EdgeInsets.all(0),
    required double height,
    double? spacing,
    required Widget Function(BuildContext context, int index) itemBuilder,
    required int itemCount,
    required Widget Function(BuildContext context) showAllBuilder,
  }) {
    return variant2(
      titlePadding: titlePadding,
      child: SizedBox(
        height: height,
        child: Padding(
          padding: listViewPadding,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemBuilder: itemBuilder,
            itemCount: itemCount,
            separatorBuilder: (context, index) => SizedBox(width: spacing),
          ),
        ),
      ),
      showAllBuilder: showAllBuilder,
    );
  }
}
