import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/utils/common.dart';

class MyColorSet {
  static final cyan = Colors.cyan.shade900;
  static final purple = Colors.deepPurple.shade300;
  static final grey = Colors.blueGrey;
  static final redAccent = Colors.redAccent.shade200;
  static final teal = Colors.teal.shade600;
  static final indigo = Colors.indigo.shade400;
  static final orange = Colors.deepOrange.shade400;
  static final pink = Colors.pink.shade900;
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

class GradBackground2 extends StatelessWidget {
  final Widget child;
  final String imageUrl;

  const GradBackground2({
    super.key,
    required this.imageUrl,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return getIt<ApiKit>().paletteColorsWidgetBuider(imageUrl, (paletteColors) {
      late final Color bgColor, subBgColor;
      if (AdaptiveTheme.of(context).mode.isDark) {
        bgColor = adjustColor(paletteColors.first, l: 0.3, s: 0.3);
        subBgColor = adjustColor(paletteColors.last, l: 0.08, s: 0.4);
      } else {
        bgColor = adjustColor(paletteColors[0], l: 0.5, s: 0.3);
        subBgColor = adjustColor(paletteColors.last, l: 0.15, s: 0.4);
      }
      return GradBackground(color: bgColor, subColor: subBgColor, child: child);
    });
  }
}
