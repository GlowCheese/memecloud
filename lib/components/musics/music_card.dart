import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:memecloud/utils/images.dart';

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
      case 1:
        return _variant1(context);
      case 2:
        return _variant2(context);
      default:
        return _variant3(context);
    }
  }

  /// with subTitle
  Widget _variant1(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          child: getImage(thumbnailUrl, 40),
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

  /// with subTitle, bigger thumbnail
  Widget _variant3(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          child: getImage(thumbnailUrl, 62),
        ),
        SizedBox(width: 14),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                subTitle!,
                style: TextStyle(
                  fontSize: 12,
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
