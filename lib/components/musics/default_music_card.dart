import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class DefaultMusicCard extends StatelessWidget {
  final String thumbnailUrl;
  final String title;
  final String subTitle;

  const DefaultMusicCard({
    super.key,
    required this.thumbnailUrl,
    required this.title,
    required this.subTitle
  });

  @override
  Widget build(BuildContext context) {
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
                subTitle,
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
