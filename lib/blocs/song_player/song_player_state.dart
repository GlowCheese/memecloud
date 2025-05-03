import 'package:equatable/equatable.dart';
import 'package:memecloud/models/song_model.dart';

abstract class SongPlayerState {}

class SongPlayerInitial extends SongPlayerState {}

class SongPlayerLoading extends SongPlayerState with EquatableMixin {
  final SongModel currentSong;
  SongPlayerLoading(this.currentSong);

  @override
  List<Object?> get props => [currentSong];
}

class SongPlayerLoaded extends SongPlayerState with EquatableMixin {
  final SongModel currentSong;
  SongPlayerLoaded(this.currentSong);

  @override
  List<Object?> get props => [currentSong];
}

class SongPlayerFailure extends SongPlayerState {}
