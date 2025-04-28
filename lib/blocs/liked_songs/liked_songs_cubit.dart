import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memecloud/blocs/liked_songs/liked_songs_state.dart';
import 'package:memecloud/models/song_model.dart';

class LikedSongsCubit extends Cubit<LikedSongsState> {
  LikedSongsCubit() : super(LikedSongInitialState());

  void toggleSongIsLiked(SongModel song, {bool? expectedTo}) {
    if (expectedTo != null) {
      assert(song.isLiked! == !expectedTo);
    }
    if (song.isLiked!) {
      song.setIsLiked(false);
      emit(UserUnlikeSong(song: song));
    } else {
      song.setIsLiked(true);
      emit(UserLikeSong(song: song));
    }
  }
}