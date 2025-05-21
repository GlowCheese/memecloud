import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class ExpandableHtml extends StatefulWidget {
  final String htmlText;
  final int trimLength;

  const ExpandableHtml({
    super.key,
    required this.htmlText,
    this.trimLength = 160,
  });

  @override
  State<ExpandableHtml> createState() => _ExpandableHtmlState();
}

class _ExpandableHtmlState extends State<ExpandableHtml> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final bool shouldTrim = widget.htmlText.length > widget.trimLength;

    final String visibleHtml = shouldTrim && !_expanded
        ? widget.htmlText.substring(0, widget.trimLength)
        : widget.htmlText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Html(data: visibleHtml),
        if (shouldTrim)
          GestureDetector(
            onTap: () {
              setState(() {
                _expanded = !_expanded;
              });
            },
            child: Text(
              _expanded ? "See less" : "... See more",
              style: TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}
