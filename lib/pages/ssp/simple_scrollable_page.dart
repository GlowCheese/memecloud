import 'package:flutter/material.dart';
import 'package:memecloud/components/miscs/default_future_builder.dart';
import 'package:memecloud/components/miscs/grad_background.dart';

class SimpleScrollablePage {
  final Key? key;
  final String title;
  final double? spacing;
  late final Color bgColor;

  SimpleScrollablePage({
    this.key,
    required this.title,
    this.spacing,
    Color? bgColor,
  }) : bgColor = bgColor ?? MyColorSet.lightBlue;

  Widget variant1({required List<Widget> children}) {
    return GradBackground(
      color: bgColor,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: Text(title), backgroundColor: Colors.transparent),
        body: ListView.separated(
          itemCount: children.length,
          itemBuilder: (context, index) => children[index],
          separatorBuilder: (context, index) => SizedBox(height: spacing),
        ),
      ),
    );
  }

  Widget variant2({required Future<List<Widget>> Function() genFunc}) {
    return GradBackground(
      color: bgColor,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: Text(title), backgroundColor: Colors.transparent),
        body: defaultFutureBuilder<List<Widget>>(
          future: genFunc(),
          onData: (context, children) {
            return ListView.separated(
              itemCount: children.length,
              itemBuilder: (context, index) => children[index],
              separatorBuilder: (context, index) => SizedBox(height: spacing),
            );
          },
        ),
      ),
    );
  }
}
