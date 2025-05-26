import 'dart:async';
import 'dart:developer';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:memecloud/core/getit.dart';
import 'package:just_audio/just_audio.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memecloud/models/song_model.dart';
import 'package:memecloud/apis/others/connectivity.dart';
import 'package:memecloud/blocs/song_player/song_player_state.dart';

class SongPlayerCubit extends Cubit<SongPlayerState> {
  AudioPlayer audioPlayer = AudioPlayer();
  List<SongModel> currentSongList = [];
  double currentSongSpeed = 1.0;

  late StreamSubscription _indexSub;

  SongPlayerCubit() : super(SongPlayerInitial()) {
    _indexSub = audioPlayer.currentIndexStream.listen((index) {
      if (index == null) {
        emit(SongPlayerInitial());
      } else {
        final newState = SongPlayerLoaded(currentSongList[index]);
        if (newState != state) {
          unawaited(getIt<ApiKit>().newSongStream(newState.currentSong));
          emit(newState);
        }
      }
    });
  }

  @override
  Future<void> close() {
    _indexSub.cancel();
    audioPlayer.dispose();
    return super.close();
  }

  bool onSongFailedToLoad(BuildContext context, String errMsg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Rất tiếc, không thể phát bài hát này!'),
        duration: Duration(seconds: 3),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
    log(errMsg, level: 900);
    emit(SongPlayerInitial());
    return false;
  }

  Future<AudioSource?> _getAudioSource(SongModel song) async {
    unawaited(getIt<ApiKit>().saveSongInfo(song));
    try {
      final uri = await getIt<ApiKit>().getSongUri(song.id);
      if (uri.scheme == 'file') {
        return AudioSource.uri(uri, tag: song.mediaItem);
      }
      return LockCachingAudioSource(uri, tag: song.mediaItem);
    } on ConnectionLoss {
      log('Connection loss while trying to get audio source. Returning null');
      return null;
    }
  }

  CancelableOperation<void>? songsPopulateTask;

  Future<bool> _loadSong(
    BuildContext context,
    SongModel song, {
    List<SongModel>? songList,
  }) async {
    try {
      debugPrint('Loading song ${song.title}');
      emit(SongPlayerLoading(song));
      await audioPlayer.stop();

      final audioSource = await _getAudioSource(song);
      if (audioSource == null) {
        return !context.mounted ||
            onSongFailedToLoad(context, 'audioSource is null');
      } else {
        currentSongList = [song];
        if (songList == null) {
          await audioPlayer.setAudioSource(audioSource);
          await audioPlayer.setLoopMode(LoopMode.off);
        } else {
          await audioPlayer.setAudioSources([audioSource]);
          await audioPlayer.setLoopMode(LoopMode.all);

          int songIdx = songList.indexOf(song);
          final remainingSongs = [
            ...songList.sublist(songIdx + 1),
            ...songList.sublist(0, songIdx),
          ];

          songsPopulateTask = CancelableOperation.fromFuture(
            lazySongPopulate(remainingSongs).catchError((e, stackTrace) {
              log(
                'Failed to populate songs: $e',
                stackTrace: stackTrace,
                level: 1000,
              );
            }),
          );
        }
        audioPlayer.setSpeed(currentSongSpeed = 1.0);
        return true;
      }
    } catch (e, stackTrace) {
      log('Failed to load song: $e', stackTrace: stackTrace, level: 1000);
      emit(SongPlayerFailure());
      return !context.mounted || onSongFailedToLoad(context, e.toString());
    }
  }

  Future<void> lazySongPopulate(List<SongModel> songList) async {
    for (SongModel song in songList) {
      final audioSource = await _getAudioSource(song);
      if (audioSource != null) {
        currentSongList.add(song);
        await audioPlayer.addAudioSource(audioSource);
      }
      if (currentSongList.length >= 5) {
        await Future.delayed(Duration(seconds: 10));
      }
    }
  }

  void playOrPause() {
    if (isPlaying) {
      audioPlayer.pause();
    } else {
      audioPlayer.play();
    }
  }

  /// Load a song and play.
  Future<void> loadAndPlay(
    BuildContext context,
    SongModel song, {
    List<SongModel>? songList,
  }) async {
    if (state is SongPlayerLoading) return;
    if (songsPopulateTask?.isCompleted == false) {
      await songsPopulateTask!.cancel();
    }

    if (context.mounted && await _loadSong(context, song, songList: songList)) {
      playOrPause();
    }
  }

  bool get isPlaying => audioPlayer.playing;

  Future<void> seekTo(Duration position) async {
    if (state is! SongPlayerLoaded) return;
    await audioPlayer.seek(position);
    emit(state);
  }

  Future<void> toggleSongSpeed() async {
    final speeds = [1.0, 1.2, 1.5, 2.0, 0.5, 0.8];
    final currentIndex = speeds.indexOf(currentSongSpeed);
    currentSongSpeed = speeds[(currentIndex + 1) % speeds.length];
    await audioPlayer.setSpeed(currentSongSpeed);
    emit(state);
  }

  bool get shuffleMode => audioPlayer.shuffleModeEnabled;

  Future<void> seekToNext() async {
    if (state is! SongPlayerLoaded) return;
    await audioPlayer.seekToNext();
    if (audioPlayer.currentIndex == null) {
      return;
    }
  }

  Future<void> seekToPrevious() async {
    if (state is! SongPlayerLoaded) return;
    await audioPlayer.seekToPrevious();
    if (audioPlayer.currentIndex == null) {
      return;
    }
  }

  Future<void> toggleShuffleMode() =>
      audioPlayer.setShuffleModeEnabled(!shuffleMode);
}
