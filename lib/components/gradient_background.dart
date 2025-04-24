import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';


class GradientBackground extends StatelessWidget {
  final String? routerName;

  const GradientBackground(this.routerName, {super.key});

  @override
  Widget build(BuildContext context) {
    final mainColor = switch(routerName) {
      '/search' => Colors.cyan.shade900,
      '/home' => Colors.deepPurple.shade300,
      _ => Colors.blueGrey
    };

    final adaptiveTheme = AdaptiveTheme.of(context);
    final themeData = adaptiveTheme.theme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [mainColor, themeData.colorScheme.surfaceDim],
          stops: [0.0, 0.4],
          begin: Alignment.topLeft,
          end: Alignment.bottomLeft,
        ),
      ),
    );
  }
}
