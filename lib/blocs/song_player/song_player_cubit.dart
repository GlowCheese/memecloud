import 'dart:async';
import 'dart:developer';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:memecloud/core/getit.dart';
import 'package:just_audio/just_audio.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memecloud/models/song_model.dart';
import 'package:memecloud/models/playlist_model.dart';
import 'package:memecloud/apis/others/connectivity.dart';
import 'package:memecloud/blocs/song_player/song_player_state.dart';
import 'package:memecloud/utils/snackbar.dart';

class SongPlayerCubit extends Cubit<SongPlayerState> {
  final audioPlayer = AudioPlayer();

  String? currentPlaylistId;
  double currentSongSpeed = 1.0;
  List<SongModel> currentSongList = [];

  late StreamSubscription _indexSub;
  late StreamSubscription _sequenceSub;
  late StreamSubscription _sequenceStateSub;

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
    _sequenceSub = audioPlayer.sequenceStream.listen((data) {
      debugPrint(data.toString());
    });
    _sequenceStateSub = audioPlayer.sequenceStateStream.listen((data) {
      debugPrint(data.toString());
    });
  }

  @override
  Future<void> close() {
    _indexSub.cancel();
    _sequenceSub.cancel();
    _sequenceStateSub.cancel();
    audioPlayer.dispose();
    return super.close();
  }

  bool onSongFailedToLoad(BuildContext context, String errMsg) {
    currentSongList.clear();
    currentPlaylistId = null;

    showErrorSnackbar(
      context,
      message: 'Rất tiếc, không thể phát bài hát này!',
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

  int? getSongIndex(String songId) {
    return currentSongList.indexWhere((song) => song.id == songId);
  }

  CancelableOperation<void>? songsPopulateTask;

  Future<bool> _loadSong(
    BuildContext context,
    SongModel song, {
    String? playlistId,
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
        currentPlaylistId = playlistId;
        if (songList == null) {
          await audioPlayer.setAudioSource(audioSource);
          await audioPlayer.setLoopMode(LoopMode.off);
        } else {
          await audioPlayer.setAudioSources([audioSource]);
          await audioPlayer.setLoopMode(LoopMode.all);

          int songIdx = getSongIndex(song.id)!;
          final remainingSongs = [
            ...songList.sublist(songIdx + 1),
            ...songList.sublist(0, songIdx),
          ];

          lazySongPopulateRunning = true;
          songsPopulateTask = CancelableOperation.fromFuture(
            lazySongPopulate(remainingSongs).onError((e, stackTrace) {
              log(
                'Failed to populate songs: $e',
                stackTrace: stackTrace,
                level: 1000,
              );
            }),
            onCancel: () => lazySongPopulateRunning = false,
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

  late bool lazySongPopulateRunning;

  Future<void> lazySongPopulate(List<SongModel> songList) async {
    for (SongModel song in songList) {
      if (!lazySongPopulateRunning) break;
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
    PlaylistModel? playlist,
    List<SongModel>? songList,
  }) async {
    if (state is SongPlayerLoading) return;
    if (currentPlaylistId != null && currentPlaylistId == playlist?.id) {
      seekTo(Duration.zero, index: getSongIndex(song.id));
      audioPlayer.play();
    } else {
      songList ??= playlist?.songs;
      if (await _loadSong(
        context,
        song,
        playlistId: playlist?.id,
        songList: songList,
      )) {
        if (playlist?.type == PlaylistType.zing ||
            playlist?.type == PlaylistType.user) {
          unawaited(getIt<ApiKit>().saveRecentlyPlayedPlaylist(playlist!));
        }
        audioPlayer.play();
      }
    }
  }

  bool get isPlaying => audioPlayer.playing;

  Future<void> seekTo(Duration position, {int? index}) async {
    if (state is! SongPlayerLoaded) return;
    await audioPlayer.seek(position, index: index);
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
