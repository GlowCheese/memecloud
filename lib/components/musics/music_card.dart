import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:memecloud/utils/images.dart';

class MusicCard extends StatelessWidget {
  /// must be between 1 and 4.
  final int variant;
  final String title;
  final Widget? icon;
  final String? subTitle;
  final String thumbnailUrl;
  final bool dimmed;
  final bool rounded;
  final double? width, height;

  const MusicCard({
    super.key,
    required this.variant,
    required this.thumbnailUrl,
    required this.title,
    this.subTitle,
    this.icon,
    this.width,
    this.height,
    this.dimmed = false,
    this.rounded = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget content;
    switch (variant) {
      case 1:
        content = _variant1(context);
        break;
      case 2:
        content = _variant2(context);
        break;
      case 3:
        content = _variant3(context);
        break;
      default:
        content = _variant4(context); // New album variant
        break;
    }

    return Opacity(opacity: dimmed ? 0.5 : 1.0, child: content);
  }

  /// with subTitle
  Widget _variant1(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          child: getImage(thumbnailUrl, 40),
        ),
        const SizedBox(width: 14),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 18),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Row(
                spacing: 8,
                children: [
                  if (icon != null) icon!,
                  Flexible(
                    child: Text(
                      subTitle!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withAlpha(180),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
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
          borderRadius: const BorderRadius.all(Radius.circular(25)),
          child: CachedNetworkImage(
            imageUrl: thumbnailUrl,
            width: 50,
            height: 50,
          ),
        ),
        const SizedBox(width: 14),
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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
        getImage(thumbnailUrl, width ?? height!),
        const SizedBox(width: 14),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
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

  /// Album/Playlist vertical card layout
  Widget _variant4(BuildContext context) {
    return SizedBox(
      width: width!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Album cover with aspect ratio
          ClipRRect(
            borderRadius:
                rounded
                    ? BorderRadius.circular((width ?? height!) / 2)
                    : BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: thumbnailUrl,
              fit: BoxFit.cover,
              width: width,
              height: height,
            ),
          ),
          const SizedBox(height: 8),
          // Album title
          Text(
            title,
            style: const TextStyle(
              height: 1.3,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (subTitle != null) ...[
            const SizedBox(height: 5),
            // Album subtitle (artist name, release date, etc.)
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
        ],
      ),
    );
  }
}
