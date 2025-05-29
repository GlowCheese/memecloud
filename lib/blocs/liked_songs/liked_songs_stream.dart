import 'dart:async';
import 'package:memecloud/models/song_model.dart';
import 'package:memecloud/blocs/liked_songs/song_like_event.dart';

class LikedSongsStream {
  final _controller = StreamController<SongLikeEvent>.broadcast();

  Stream<SongLikeEvent> get stream => _controller.stream;

  void setIsLiked(SongModel song, bool isLiked) {
    if (isLiked) {
      _controller.add(UserLikeSongEvent(song: song));
    } else {
      _controller.add(UserUnlikeSongEvent(song: song));
    }
  }

  void dispose() {
    _controller.close();
  }
}
