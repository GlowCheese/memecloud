import 'dart:async';
import 'package:memecloud/models/song_model.dart';

class SongLikeEvent {}

class UserLikeSongEvent extends SongLikeEvent {
  final SongModel song;
  UserLikeSongEvent({required this.song});
}

class UserUnlikeSongEvent extends SongLikeEvent {
  final SongModel song;
  UserUnlikeSongEvent({required this.song});
}

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
