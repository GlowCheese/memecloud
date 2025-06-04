import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

class HubCard {
  final Key? key;
  final String hubId;
  final String title;
  final String thumbnailHasText;

  HubCard({
    this.key,
    required this.hubId,
    required this.title,
    required this.thumbnailHasText,
  });

  Widget _gestureDectectorWrapper(
    BuildContext context, {
    required Widget child,
  }) {
    return GestureDetector(
      onTap: () => context.push('/hub_page', extra: hubId),
      child: child,
    );
  }

  Widget variant1({required double width, required double height}) {
    return Builder(
      builder: (context) {
        return _gestureDectectorWrapper(
          context,
          child: ClipRRect(
            borderRadius: BorderRadiusGeometry.circular(10),
            child: CachedNetworkImage(
              imageUrl: thumbnailHasText,
              width: width,
              height: height,
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }
}
