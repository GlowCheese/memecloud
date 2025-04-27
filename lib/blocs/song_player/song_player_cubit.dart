import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/models/song_model.dart';
import 'package:memecloud/blocs/song_player/song_player_state.dart';

class SongPlayerCubit extends Cubit<SongPlayerState> {
  AudioPlayer audioPlayer = AudioPlayer();
  Duration songDuration = Duration.zero;
  Duration songPosition = Duration.zero;

  SongModel? currentSong;

  late StreamSubscription<Duration> _positionSub;
  late StreamSubscription<Duration?> _durationSub;

  SongPlayerCubit() : super(SongPlayerInitial()) {
    _positionSub = audioPlayer.positionStream.listen((position) {
      songPosition = position;
      if (currentSong != null) {
        emit(SongPlayerLoaded());
      }
    });

    _durationSub = audioPlayer.durationStream.listen((duration) {
      if (duration != null) {
        songDuration = duration;
      }
    });
  }

  bool onSongFailedToLoad(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Rất tiếc, không thể phát bài hát này!'),
        duration: Duration(seconds: 3),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
    currentSong = null;
    emit(SongPlayerInitial());
    return false;
  }

  Future<bool> loadSong(BuildContext context, SongModel song) async {
    try {
      if (currentSong == song) return false;
      currentSong = song;
      debugPrint('Loading song ${song.title}');
      emit(SongPlayerLoading());
      await audioPlayer.stop();

      final check = await getIt<ApiKit>().isNonVipSong(song.id);
      return check.fold(
        (l) => !context.mounted || onSongFailedToLoad(context),
        (r) async {
          if (!r) return !context.mounted || onSongFailedToLoad(context);
          getIt<ApiKit>().saveSongInfo(song);
          final songPath = await getIt<ApiKit>().getSongPath(song.id);
          return songPath.fold((l) => onSongFailedToLoad(context), (r) async {
            if (r == null) {
              return onSongFailedToLoad(context);
            } else {
              debugPrint('Song path: $r');
              await audioPlayer.setFilePath(r);
              emit(SongPlayerLoaded());
              return true;
            }
          });
        },
      );
    } catch (e) {
      emit(SongPlayerFailure());
      return !context.mounted || onSongFailedToLoad(context);
    }
  }

  void playOrPause() {
    if (audioPlayer.playing) {
      audioPlayer.pause();
    } else {
      audioPlayer.play();
    }
    emit(SongPlayerLoaded());
  }

  /// Load a song and play. \
  /// If the player is loading another song, return `true`. \
  /// Otherwise, return `true` if the song can be played \
  /// (i.e. `isNonVipSong(song) == true`).
  Future<bool> loadAndPlay(BuildContext context, SongModel song) async {
    if (state is SongPlayerLoading) {
      return true;
    }
    if (await loadSong(context, song)) {
      playOrPause();
      return true;
    }
    return false;
  }

  void seekTo(Duration position) {
    audioPlayer.seek(position);
    emit(SongPlayerLoaded());
  }

  @override
  Future<void> close() {
    _positionSub.cancel();
    _durationSub.cancel();
    audioPlayer.dispose();
    return super.close();
  }
}
