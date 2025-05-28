import 'dart:async';
import 'package:flutter/material.dart';
import 'package:memecloud/utils/common.dart';
import 'package:adaptive_theme/adaptive_theme.dart';

class MyColorSet {
  static final cyan = Colors.cyan.shade900;
  static final purple = Colors.deepPurple.shade300;
  static final grey = Colors.blueGrey;
  static final redAccent = Colors.redAccent.shade200;
  static final teal = const Color.fromRGBO(0, 137, 123, 1);
  static final indigo = Colors.indigo.shade400;
  static final orange = Colors.deepOrange.shade400;
  static final green = Colors.green.shade700;
  static final amber = Colors.amber.shade800;
  static final lightBlue = Colors.lightBlue.shade700;
}

class GradBackground extends StatelessWidget {
  final Widget child;
  late final Color color;
  final Color? subColor;

  GradBackground({
    super.key,
    Color? color,
    this.subColor,
    required this.child,
  }) {
    this.color = color ?? MyColorSet.grey;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = AdaptiveTheme.of(context).theme.colorScheme;

    return Stack(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, subColor ?? colorScheme.surfaceDim],
              stops: [0.0, 0.4],
              begin: Alignment.topLeft,
              end: Alignment.bottomLeft,
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class GradBackground2 extends StatefulWidget {
  final String imageUrl;
  final Widget Function(Color bgColor, Color subBgColor) builder;

  const GradBackground2({
    super.key,
    required this.imageUrl,
    required this.builder,
  });

  @override
  State<GradBackground2> createState() => _GradBackground2State();
}

class _GradBackground2State extends State<GradBackground2> {
  List<Color> paletteColors = List.filled(2, Colors.white);

  Future<void> loadPaletteColors() {
    return getPaletteColors(widget.imageUrl).then((data) {
      setState(() => paletteColors = data);
    });
  }

  @override
  void didUpdateWidget(covariant GradBackground2 oldWidget) {
    super.didUpdateWidget(oldWidget);
    unawaited(loadPaletteColors());
  }

  @override
  void initState() {
    super.initState();
    unawaited(loadPaletteColors());
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = adjustColor(paletteColors.first, l: 0.5, s: 0.3);
    final subBgColor = adjustColor(paletteColors.last, l: 0.1, s: 0.4);
    return GradBackground(
      color: bgColor,
      subColor: subBgColor,
      child: widget.builder(bgColor, subBgColor),
    );
  }
}
