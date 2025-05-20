import 'package:flutter/material.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/models/song_model.dart';
import 'package:memecloud/blocs/liked_songs/liked_songs_stream.dart';

class SongLikeButton extends StatefulWidget {
  final SongModel song;
  final Color dftColor;
  final bool defaultIsLiked;

  const SongLikeButton({
    super.key,
    required this.song,
    this.dftColor = Colors.white,
    this.defaultIsLiked = false,
  });

  @override
  State<SongLikeButton> createState() => _SongLikeButtonState();
}

class _SongLikeButtonState extends State<SongLikeButton> {
  void _syncLike(AsyncSnapshot<SongLikeEvent> snapshot) {
    final event = snapshot.data;
    SongModel? song;

    if (event is UserLikeSongEvent) song = event.song;
    if (event is UserUnlikeSongEvent) song = event.song;

    if (song != null && song.id == widget.song.id) {
      widget.song.isLiked = song.isLiked;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: getIt<LikedSongsStream>().stream,
      builder: (context, snapshot) {
        _syncLike(snapshot);
        return IconButton(
          icon:
              widget.song.isLiked == true
                  ? Icon(Icons.favorite_rounded, color: Colors.red.shade400)
                  : Icon(
                    Icons.favorite_outline_rounded,
                    color: widget.dftColor,
                  ),
          onPressed: () {
            widget.song.isLiked = widget.song.isLiked != true;
          },
        );
      },
    );
  }
}
