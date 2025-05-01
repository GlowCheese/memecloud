import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';

class MyColorSet {
  static final cyan = Colors.cyan.shade900;
  static final purple = Colors.deepPurple.shade300;
  static final grey = Colors.blueGrey;
  static final redAccent = Colors.redAccent.shade200;
  static final teal = Colors.teal.shade600;
  static final indigo = Colors.indigo.shade400;
  static final orange = Colors.deepOrange.shade400;
  static final pink = Colors.pink.shade400;
  static final green = Colors.green.shade700;
  static final amber = Colors.amber.shade800;
  static final lightBlue = Colors.lightBlue.shade700;
}

class GradBackground extends StatelessWidget {
  final Widget child;
  late final Color color;

  GradBackground({super.key, Color? color, required this.child}) {
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
              colors: [color, colorScheme.surfaceDim],
              stops: [0.0, 0.4],
              begin: Alignment.topLeft,
              end: Alignment.bottomLeft,
            ),
          ),
        ),
        child
      ],
    );
  }
}