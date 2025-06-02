import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';


class CodeBlock extends StatelessWidget {
  final String text;
  final double fontSize;
  
  const CodeBlock(this.text, {super.key, this.fontSize=14});

  @override
  Widget build(BuildContext context) {
    final themeData = AdaptiveTheme.of(context).theme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.black12,
        border: Border.all(color: themeData.colorScheme.onSurface),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: fontSize,
          color: themeData.colorScheme.onSurface,
        ),
      ),
    );
  }
}
