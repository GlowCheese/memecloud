import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:memecloud/utils/common.dart';

class RotatingSongDisc extends StatefulWidget {
  final String thumbnailUrl;
  final bool isPlaying;
  final Color holeColor;
  final double size;

  const RotatingSongDisc({
    super.key,
    required this.thumbnailUrl,
    required this.isPlaying,
    required this.holeColor,
    required this.size,
  });

  @override
  State<RotatingSongDisc> createState() => _RotatingSongDiscState();
}

class _RotatingSongDiscState extends State<RotatingSongDisc>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    duration: const Duration(seconds: 10),
    vsync: this,
  )..repeat();

  @override
  void didUpdateWidget(covariant RotatingSongDisc oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying) {
      _controller.repeat();
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        RotationTransition(
          turns: _controller,
          child: ClipOval(
            child: SizedBox(
              width: widget.size,
              height: widget.size,
              child: CachedNetworkImage(
                fit: BoxFit.cover,
                imageUrl: widget.thumbnailUrl,
              ),
            ),
          ),
        ),
        Container(
          width: widget.size / 4 + 8,
          height: widget.size / 4 + 8,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(widget.size / 8 + 4),
          ),
        ),
        Container(
          width: widget.size / 4,
          height: widget.size / 4,
          decoration: BoxDecoration(
            color: adjustColor(widget.holeColor, l: 0.2),
            borderRadius: BorderRadius.circular(widget.size / 8),
          ),
        ),
      ],
    );
  }
}
