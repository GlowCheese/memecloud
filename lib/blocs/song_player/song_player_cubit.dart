import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:memecloud/core/getit.dart';
import 'package:just_audio/just_audio.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memecloud/apis/connectivity.dart';
import 'package:memecloud/models/song_model.dart';
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
        emit(SongPlayerLoaded(currentSongList[index]));
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

  Future<Uri?> _getSongUri(SongModel song) async {
    unawaited(getIt<ApiKit>().saveSongInfo(song));
    try {
      return await getIt<ApiKit>().getSongUri(song.id);
    } on ConnectionLoss {
      return null;
    }
  }

  Future<bool> _loadSong(
    BuildContext context,
    SongModel song, {
    List<SongModel>? songList,
  }) async {
    try {
      debugPrint('Loading song ${song.title}');
      emit(SongPlayerLoading(song));
      await audioPlayer.stop();

      final songUri = await _getSongUri(song);
      if (songUri == null) {
        return !context.mounted ||
            onSongFailedToLoad(context, 'songPath is null');
      } else {
        debugPrint('Found song path: $songUri');
        currentSongList = [song];
        if (songList == null) {
          await audioPlayer.setAudioSource(
            AudioSource.uri(songUri, tag: song.mediaItem),
          );
          await audioPlayer.setLoopMode(LoopMode.one);
        } else {
          await audioPlayer.setAudioSources([
            AudioSource.uri(songUri, tag: song.mediaItem),
          ]);
          await audioPlayer.setLoopMode(LoopMode.all);

          int songIdx = songList.indexOf(song);
          final remainingSongs = [
            ...songList.sublist(songIdx + 1),
            ...songList.sublist(0, songIdx),
          ];

          unawaited(
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
        await toggleShuffleMode();
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
      if (state is! SongPlayerLoaded) return Future.value();
      final songUri = await _getSongUri(song);
      if (songUri != null) {
        currentSongList.add(song);
        await audioPlayer.addAudioSource(
          AudioSource.uri(songUri, tag: song.mediaItem),
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
      // getIt<SupabaseApi>().songs.incrementView(song.id);
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
  Future<void> seekToNext() => audioPlayer.seekToNext();

  Future<void> seekToPrevious() => audioPlayer.seekToPrevious();
  Future<void> toggleShuffleMode() =>
      audioPlayer.setShuffleModeEnabled(!shuffleMode);
}
