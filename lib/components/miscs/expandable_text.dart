import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class ExpandableText extends StatefulWidget {
  final String text;
  final int trimLength;

  const ExpandableText({
    super.key,
    required this.text,
    this.trimLength = 30,
  });

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final bool shouldTrim = widget.text.length > widget.trimLength;
    final String visibleText = shouldTrim && !_expanded
        ? widget.text.substring(0, widget.trimLength)
        : widget.text;

    final String toggleText = shouldTrim ? (_expanded ? ' See less' : '... See more') : '';

    return RichText(
      text: TextSpan(
        style: TextStyle(color: Colors.white, fontSize: 16),
        children: [
          TextSpan(text: visibleText),
          if (shouldTrim)
            TextSpan(
              text: toggleText,
              style: TextStyle(
                color: Colors.white.withAlpha(180),
                fontWeight: FontWeight.bold,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  setState(() {
                    _expanded = !_expanded;
                  });
                },
            ),
        ],
      ),
    );
  }
}