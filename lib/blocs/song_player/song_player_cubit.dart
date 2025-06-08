import 'dart:async';
import 'dart:developer';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:memecloud/apis/firebase/main.dart';
import 'package:memecloud/core/getit.dart';
import 'package:just_audio/just_audio.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:memecloud/utils/snackbar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memecloud/models/song_model.dart';
import 'package:memecloud/models/playlist_model.dart';
import 'package:memecloud/apis/others/connectivity.dart';
import 'package:memecloud/blocs/song_player/song_player_state.dart';
import 'package:memecloud/blocs/song_player/custom_audio_player.dart';

class SongPlayerCubit extends Cubit<SongPlayerState> {
  final audioPlayer = CustomAudioPlayer();

  final apiKit = getIt<ApiKit>();
  final firebaseApi = getIt<FirebaseApi>();

  String lastSongId = "";
  PlaylistModel? currentPlaylist;
  late final StreamSubscription _currentSongSub;

  SongPlayerCubit() : super(SongPlayerInitial()) {
    _currentSongSub = audioPlayer.currentSongStream.listen((song) {
      if (song == null) {
        emit(SongPlayerInitial());
      } else if (song.id != lastSongId) {
        lastSongId = song.id;
        unawaited(
          apiKit.getSongUri(song.id).then((uri) {
            firebaseApi.uploadSong(uri: uri, songId: song.id);
          }),
        );
        unawaited(getIt<ApiKit>().newSongStream(song));
      }
    });
  }

  @override
  Future<void> close() {
    _currentSongSub.cancel();
    audioPlayer.dispose();
    return super.close();
  }

  Future<bool> onSongFailedToLoad(BuildContext context, String errMsg) async {
    await audioPlayer.reset();
    currentPlaylist = null;

    if (context.mounted) {
      showErrorSnackbar(context, message: 'Lỗi: $errMsg!');
    }

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

  late bool lazySongPopulateRunning;
  CancelableOperation<void>? songsPopulateTask;

  Future<bool> _loadSong(
    BuildContext context,
    SongModel song, {
    PlaylistModel? playlist,
    List<SongModel>? songList,
  }) async {
    try {
      debugPrint('Loading song ${song.title}');
      emit(SongPlayerLoading(song));

      await songsPopulateTask?.cancel();
      await audioPlayer.reset();

      final audioSource = await _getAudioSource(song);
      if (audioSource == null) {
        return !context.mounted ||
            await onSongFailedToLoad(context, 'Connection loss');
      }
      currentPlaylist = playlist;

      if (songList == null) {
        await audioPlayer.ready(song, audioSource, isPlaylist: false);
      } else {
        await audioPlayer.ready(song, audioSource, isPlaylist: true);

        int songIdx = songList.indexOf(song);
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
      audioPlayer.setSpeed(1.0);
      emit(SongPlayerLoaded());
      return true;
    } catch (e, stackTrace) {
      log('Failed to load song: $e', stackTrace: stackTrace, level: 1000);
      emit(SongPlayerFailure());
      return !context.mounted ||
          await onSongFailedToLoad(context, e.toString());
    }
  }

  Future<void> lazySongPopulate(List<SongModel> songList) async {
    for (SongModel song in songList) {
      if (!lazySongPopulateRunning) break;
      await Future.delayed(const Duration(milliseconds: 500));
      if (!lazySongPopulateRunning) break;
      final audioSource = await _getAudioSource(song);
      if (!lazySongPopulateRunning) break;
      if (audioSource != null) {
        await audioPlayer.addSong(song, audioSource);
      }
    }
  }

  /// Load a song and play. Do nothing if state is SongPlayerLoading
  Future<void> loadAndPlay(
    BuildContext context,
    SongModel song, {
    PlaylistModel? playlist,
    List<SongModel>? songList,
  }) async {
    if (state is SongPlayerLoading) return;
    if (currentPlaylist != null && currentPlaylist!.id == playlist?.id) {
      seek(Duration.zero, songId: song.id);
      await audioPlayer.play();
    } else {
      songList ??= playlist?.songs;
      if (context.mounted &&
          await _loadSong(
            context,
            song,
            playlist: playlist,
            songList: songList,
          )) {
        if (playlist?.type == PlaylistType.zing ||
            playlist?.type == PlaylistType.user) {
          unawaited(getIt<ApiKit>().saveRecentlyPlayedPlaylist(playlist!));
        }
        await audioPlayer.play();
      }
    }
  }

  Future<void> seek(Duration position, {String? songId}) async {
    if (state is! SongPlayerLoaded) return;
    if (songId == null) {
      return await audioPlayer.seek(position);
    }
    await audioPlayer.seek(position, index: audioPlayer.getIndexOf(songId));
  }

  Future<void> seekToNext() async {
    if (state is! SongPlayerLoaded) return;
    await audioPlayer.seekToNext();
  }

  Future<void> seekToPrevious() async {
    if (state is! SongPlayerLoaded) return;
    await audioPlayer.seekToPrevious();
  }

  double get speed => audioPlayer.speed;
  bool get isPlaying => audioPlayer.playing;
  bool get shuffleMode => audioPlayer.shuffleModeEnabled;
  Future<void> playOrPause() => audioPlayer.playOrPause();
  Future<void> toggleSongSpeed() => audioPlayer.toggleSongSpeed();
  Future<void> toggleShuffleMode() => audioPlayer.toggleShuffleMode();
}
