import 'dart:async';

import 'package:flutter/material.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/models/playlist_model.dart';
import 'package:skeletonizer/skeletonizer.dart';

class PlaylistFollowButton extends StatefulWidget {
  final PlaylistModel playlist;
  final double? iconSize;
  final bool withFolowerCount;

  const PlaylistFollowButton({
    super.key,
    this.iconSize,
    required this.playlist,
    this.withFolowerCount = false,
  });

  @override
  State<PlaylistFollowButton> createState() => _PlaylistFollowButtonState();
}

class _PlaylistFollowButtonState extends State<PlaylistFollowButton> {
  bool _isFollowing = false;
  int? _followerCount;

  @override
  void initState() {
    super.initState();
    _isFollowing = widget.playlist.isFollowed;
    if (widget.withFolowerCount) {
      unawaited(
        getIt<ApiKit>()
            .getPlaylistFollowerCounts(widget.playlist.id)
            .then((value) => setState(() => _followerCount = value)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final button = IconButton(
      iconSize: widget.iconSize,
      icon:
          _isFollowing
              ? Icon(Icons.favorite_rounded, color: Colors.red.shade400)
              : Icon(Icons.favorite_outline_rounded, color: Colors.white),
      onPressed: () {
        setState(() {
          _isFollowing = !_isFollowing;
          if (_followerCount != null) {
            _followerCount = _followerCount! + (_isFollowing ? 1 : -1);
          }
          widget.playlist.isFollowed = _isFollowing;
        });
      },
    );

    if (!widget.withFolowerCount) {
      return button;
    } else {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          button,
          if (_followerCount != null)
            Text(
              '$_followerCount likes',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            )
          else
            Skeletonizer(
              child: Text(
                BoneMock.words(1),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      );
    }
  }
}
