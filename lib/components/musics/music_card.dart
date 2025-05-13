import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MusicCard extends StatelessWidget {
  /// must be between 1 and 2.
  final int variation;
  final String title;
  final String? subTitle;
  final String thumbnailUrl;

  const MusicCard({
    super.key,
    required this.variation,
    required this.thumbnailUrl,
    required this.title,
    this.subTitle,
  });

  @override
  Widget build(BuildContext context) {
    if (variation == 1) {
      return _variation1(context);
    }
    return _variation2(context);
  }

  Widget _variation2(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(25)),
          child: CachedNetworkImage(
            imageUrl: thumbnailUrl,
            width: 50,
            height: 50,
          ),
        ),
        SizedBox(width: 14),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _variation1(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          child: CachedNetworkImage(
            imageUrl: thumbnailUrl,
            width: 40,
            height: 40,
          ),
        ),
        SizedBox(width: 14),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 18),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                subTitle!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withAlpha(180),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
