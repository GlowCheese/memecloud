import 'package:flutter/material.dart';
import 'package:memecloud/components/miscs/grad_background.dart';

class SimpleScrollablePage extends StatelessWidget {
  final String title;
  final double? spacing;
  final List<Widget> items;
  late final Color bgColor;

  SimpleScrollablePage({
    super.key,
    required this.title,
    required this.items,
    Color? bgColor,
    this.spacing,
  }) : bgColor = bgColor ?? MyColorSet.lightBlue;

  @override
  Widget build(BuildContext context) {
    return GradBackground(
      color: bgColor,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: Text(title), backgroundColor: Colors.transparent),
        body: ListView.separated(
          itemCount: items.length,
          itemBuilder: (context, index) => items[index],
          separatorBuilder: (context, index) => SizedBox(height: spacing),
        ),
      ),
    );
  }
}
