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
