import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class ExpandableText extends StatefulWidget {
  final String text;
  final int trimLength;
  final TextStyle? textStyle;
  final TextStyle? expandTextStyle;

  const ExpandableText(
    this.text, {
    super.key,
    this.textStyle,
    this.expandTextStyle,
    this.trimLength = 160,
  });

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final bool shouldTrim = widget.text.length > widget.trimLength;

    final String visibleText =
        shouldTrim && !_expanded
            ? widget.text.substring(0, widget.trimLength)
            : widget.text;

    return RichText(
      text: TextSpan(
        text: visibleText,
        style: widget.textStyle,
        children: [
          if (shouldTrim)
            TextSpan(
              text: _expanded ? " See less" : "... See more",
              style: widget.expandTextStyle,
              recognizer:
                  TapGestureRecognizer()
                    ..onTap = () => setState(() => _expanded = !_expanded),
            ),
        ],
      ),
    );
  }
}
