import 'dart:async';
import 'package:flutter/material.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/apis/connectivity.dart';
import 'package:memecloud/models/song_model.dart';
import 'package:memecloud/blocs/liked_songs/liked_songs_stream.dart';

class SongLikeButton extends StatelessWidget {
  final SongModel song;
  final Color dftColor;
  final bool defaultIsLiked;

  SongLikeButton({
    super.key,
    required this.song,
    required this.dftColor,
    this.defaultIsLiked = false
  }) {
    if (song.isLiked == null) {
      song.setIsLiked(defaultIsLiked, sync: false);
      unawaited(() async {
        try {
          await song.loadIsLiked();
        } on ConnectionLoss { return; }
      }());
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: getIt<LikedSongsStream>().stream,
      builder: (context, snapshot) {
        return IconButton(
          icon:
              song.isLiked == true
                  ? Icon(Icons.favorite_rounded, color: Colors.red.shade400)
                  : Icon(Icons.favorite_outline_rounded, color: dftColor),
          onPressed: () {
            song.setIsLiked(song.isLiked != true);
          },
        );
      }
    );
  }
}
