import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:memecloud/core/getit.dart';
import 'package:just_audio/just_audio.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memecloud/models/song_model.dart';
import 'package:memecloud/blocs/song_player/song_player_state.dart';

class SongPlayerCubit extends Cubit<SongPlayerState> {
  AudioPlayer audioPlayer = AudioPlayer();
  List<SongModel>? currentSongList;
  double currentSongSpeed = 1.0;
  late StreamSubscription _indexSub;

  SongPlayerCubit() : super(SongPlayerInitial()) {
    _indexSub = audioPlayer.currentIndexStream.listen((index) {
      if (index == null) {
        emit(SongPlayerInitial());
      } else {
        emit(SongPlayerLoaded(currentSongList![index]));
      }
    });
  }

  @override
  Future<void> close() {
    _indexSub.cancel();
    audioPlayer.dispose();
    return super.close();
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
    emit(SongPlayerInitial());
    return false;
  }

  Future<String?> _getSongPath(SongModel song) async {
    await song.loadIsLiked();
    return (await getIt<ApiKit>().getSongPath(
      song.id,
    )).fold((l) => null, (r) => r);
  }

  Future<bool> _loadSong(
    BuildContext context,
    SongModel song, {
    List<SongModel>? songList,
  }) async {
    try {
      debugPrint('Loading song ${song.title}');
      await song.loadIsLiked();
      emit(SongPlayerLoading(song));
      await audioPlayer.stop();

      final songPath = await _getSongPath(song);
      if (songPath == null) {
        return !context.mounted || onSongFailedToLoad(context);
      } else {
        getIt<ApiKit>().saveSongInfo(song);
        debugPrint('Found song path: $songPath');
        if (songList == null) {
          currentSongList = null;
          await audioPlayer.setAudioSource(
            AudioSource.file(songPath, tag: song.mediaItem),
          );
          await audioPlayer.setLoopMode(LoopMode.off);
        } else {
          currentSongList = [song];
          await audioPlayer.setAudioSources([
            AudioSource.file(songPath, tag: song.mediaItem),
          ]);
          await audioPlayer.setLoopMode(LoopMode.all);

          unawaited(
            lazySongPopulate(song, songList).catchError((e, stackTrace) {
              log(
                'Failed to populate songs: $e',
                stackTrace: stackTrace,
                level: 1000,
              );
            }),
          );
        }
        audioPlayer.setSpeed(currentSongSpeed = 1.0);
        emit(SongPlayerLoaded(song));
        return true;
      }
    } catch (e) {
      emit(SongPlayerFailure());
      return !context.mounted || onSongFailedToLoad(context);
    }
  }

  Future<void> lazySongPopulate(
    SongModel song,
    List<SongModel> songList,
  ) async {
    int initialSongIdx = songList.indexOf(song);

    for (song in [
      ...songList.sublist(initialSongIdx + 1),
      ...songList.sublist(0, initialSongIdx + 1),
    ]) {
      if (state is! SongPlayerLoaded) return Future.value();
      final songPath = await _getSongPath(song);
      if (songPath != null) {
        getIt<ApiKit>().saveSongInfo(song);
        currentSongList!.add(song);
        await audioPlayer.addAudioSource(
          AudioSource.file(songPath, tag: song.mediaItem),
        );
      }
    }
  }

  void playOrPause() {
    if (isPlaying) {
      audioPlayer.pause();
    } else {
      audioPlayer.play();
    }
    emit(state);
  }

  /// Load a song and play. \
  /// If the player is loading another song, return `true`. \
  /// Otherwise, return `true` if the song can be played \
  /// (i.e. `isNonVipSong(song) == true`).
  Future<bool> loadAndPlay(
    BuildContext context,
    SongModel song, {
    List<SongModel>? songList,
  }) async {
    if (state is SongPlayerLoading) {
      return true;
    }
    if (await _loadSong(context, song, songList: songList)) {
      playOrPause();
      return true;
    }
    return false;
  }

  bool get isPlaying => audioPlayer.playing;

  Future<void> seekTo(Duration position) async {
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
  Future<void> seekToNext() async => await audioPlayer.seekToNext();

  Future<void> seekToPrevious() async => await audioPlayer.seekToPrevious();
  Future<void> toggleShuffleMode() async =>
      await audioPlayer.setShuffleModeEnabled(!shuffleMode);
}
