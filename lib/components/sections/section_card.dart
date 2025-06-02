import 'package:flutter/material.dart';

class SectionCard {
  static Widget variant1({
    Key? key,
    required String title,
    Widget? showAllButton,
    EdgeInsetsGeometry? titlePadding,
    required List<Widget> children,
  }) => _SectionCardVariant1(
    key: key,
    title,
    showAllButton,
    titlePadding,
    children,
  );
}

class _SectionCardVariant1 extends StatelessWidget {
  final String title;
  final Widget? showAllButton;
  final EdgeInsetsGeometry? titlePadding;
  final List<Widget> children;

  const _SectionCardVariant1(
    this.title,
    this.showAllButton,
    this.titlePadding,
    this.children, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final titleRow = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        if (showAllButton != null) showAllButton!,
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (titlePadding == null)
          titleRow
        else
          Padding(padding: titlePadding!, child: titleRow),
        ...children,
      ],
    );
  }
}
