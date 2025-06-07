import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memecloud/utils/common.dart';
import 'package:memecloud/utils/images.dart';

class SectionItemCard {
  static Widget variation1({
    Key? key,
    required String playlistId,
    required String title,
    required String description,
    required String tag,
    required String thumbnailUrl,
    double gap = 12,
    double height = 152,
  }) {
    return _SectionItemCardVariation1(
      playlistId,
      title,
      description,
      tag,
      thumbnailUrl,
      gap,
      height,
      key: key,
    );
  }
}

class _SectionItemCardVariation1 extends StatefulWidget {
  final String playlistId;
  final String title;
  final String description;
  final String tag;
  final String thumbnailUrl;
  final double gap;
  final double height;

  const _SectionItemCardVariation1(
    this.playlistId,
    this.title,
    this.description,
    this.tag,
    this.thumbnailUrl,
    this.gap,
    this.height, {
    super.key,
  });

  @override
  State<_SectionItemCardVariation1> createState() =>
      _SectionItemCardVariation1State();
}

class _SectionItemCardVariation1State
    extends State<_SectionItemCardVariation1> {
  Color domColor = Colors.white;
  Color tlColor = Colors.grey.shade500;
  Color brColor = Colors.grey.shade900;

  Future<void> loadDominateColor() {
    return getDominantColor(widget.thumbnailUrl).then((data) {
      setState(() {
        domColor = data!;
        tlColor = adjustColor(domColor, l: 0.6);
        brColor = adjustColor(domColor, l: 0.2);
      });
    });
  }

  @override
  void didUpdateWidget(covariant _SectionItemCardVariation1 oldWidget) {
    super.didUpdateWidget(oldWidget);
    unawaited(loadDominateColor());
  }

  @override
  void initState() {
    super.initState();
    unawaited(loadDominateColor());
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/playlist_page', extra: widget.playlistId),
      child: Container(
        width: double.infinity,
        height: widget.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [tlColor, brColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: EdgeInsets.all(widget.gap),
        alignment: Alignment.center,
        child: Row(
          spacing: widget.gap,
          children: [
            getImage(widget.thumbnailUrl, widget.height - 2 * widget.gap),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(60),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 5,
                      horizontal: 10,
                    ),
                    child: Text(
                      widget.tag,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    widget.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withAlpha(180),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
