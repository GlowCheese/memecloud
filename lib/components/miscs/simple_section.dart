import 'package:flutter/material.dart';
import 'package:memecloud/pages/library/library_page.dart';

// TODO: goofy ahh name
class SimpleSection extends StatelessWidget {
  final String title;
  final Widget? showAllButton;
  final List<Widget> children;

  const SimpleSection({
    super.key,
    required this.title,
    this.showAllButton,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: horzPad,
            right: horzPad,
            top: 18,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              if (showAllButton != null) showAllButton!,
            ],
          ),
        ),
        ...children,
      ],
    );
  }
}
