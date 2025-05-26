import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MusicCard extends StatelessWidget {
  /// must be between 1 and 3.
  final int variant;
  final String title;
  final String? subTitle;
  final String thumbnailUrl;

  const MusicCard({
    super.key,
    required this.variant,
    required this.thumbnailUrl,
    required this.title,
    this.subTitle,
  });

  @override
  Widget build(BuildContext context) {
    switch (variant) {
      case 1: return _variant1(context, [40, 14, 18, 14]);
      case 2: return _variant2(context);
      default: return _variant1(context, [45, 16, 19, 15]);
    }
  }

  /// with subTitle
  Widget _variant1(BuildContext context, List<double> sizes) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          child: CachedNetworkImage(
            imageUrl: thumbnailUrl,
            width: sizes[0],
            height: sizes[0],
          ),
        ),
        SizedBox(width: sizes[1]),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: sizes[2]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                subTitle!,
                style: TextStyle(
                  fontSize: sizes[3],
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

  /// without subTitle
  Widget _variant2(BuildContext context) {
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
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
