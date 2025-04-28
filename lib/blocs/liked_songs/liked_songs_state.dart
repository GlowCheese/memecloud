import 'package:memecloud/models/song_model.dart';

class LikedSongsState {}

class LikedSongInitialState extends LikedSongsState {}

class UserLikeSong extends LikedSongsState {
  final SongModel song;
  UserLikeSong({required this.song});
}

class UserUnlikeSong extends LikedSongsState {
  final SongModel song;
  UserUnlikeSong({required this.song});
}