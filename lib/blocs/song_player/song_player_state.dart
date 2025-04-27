import 'package:memecloud/models/song_model.dart';

abstract class SongPlayerState {}

class SongPlayerInitial extends SongPlayerState {}
class SongPlayerLoading extends SongPlayerState {
  final SongModel currentSong;
  SongPlayerLoading(this.currentSong);
}
class SongPlayerLoaded extends SongPlayerState {
  final SongModel currentSong;
  SongPlayerLoaded(this.currentSong);
}
class SongPlayerFailure extends SongPlayerState {}
