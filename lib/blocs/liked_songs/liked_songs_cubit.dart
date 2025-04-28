import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memecloud/blocs/liked_songs/liked_songs_state.dart';
import 'package:memecloud/models/song_model.dart';

class LikedSongsCubit extends Cubit<LikedSongsState> {
  LikedSongsCubit() : super(LikedSongInitialState());

  void setIsLiked(SongModel song, bool isLiked) {
    if (isLiked) {
      emit(UserLikeSong(song: song));
    } else {
      emit(UserUnlikeSong(song: song));
    }
  }
}