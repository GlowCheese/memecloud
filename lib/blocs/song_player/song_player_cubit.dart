import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
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
      emit(SongPlayerLoaded());
    });

    _durationSub = audioPlayer.durationStream.listen((duration) {
      if (duration != null) {
        songDuration = duration;
      }
    });
  }

  Future<void> loadSong(SongModel song) async {
    try {
      if (currentSong != song) {
        await audioPlayer.stop();
        currentSong = song;
        await audioPlayer.setUrl(song.url);
        emit(SongPlayerLoaded());
      }
    } catch (e) {
      emit(SongPlayerFailure());
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

  Future<void> loadAndPlay(SongModel song) async {
    await loadSong(song);
    playOrPause();
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
