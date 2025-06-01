import 'dart:async';

import 'package:just_audio/just_audio.dart';
import 'package:memecloud/models/song_model.dart';
import 'package:rxdart/rxdart.dart';

class CustomAudioPlayer extends AudioPlayer {
  /// `null` if no song is playing, `SongModel` otherwise.
  SongModel? currentSong;

  List<SongModel> songList = [];
  List<int> listenHistory = [];
  List<int> upcomingSongs = [];

  late final BehaviorSubject<SongModel?> _currentSongSubject;
  late final BehaviorSubject<List<int>> _listenHistorySubject;
  late final BehaviorSubject<List<int>> _upcomingSongsSubject;

  Stream<SongModel?> get currentSongStream => _currentSongSubject.stream;
  Stream<List<int>> get listenHistoryStream => _listenHistorySubject.stream;
  Stream<List<int>> get upcomingSongsStream => _upcomingSongsSubject.stream;

  CustomAudioPlayer(): super() {
    _currentSongSubject = BehaviorSubject.seeded(null);
    _listenHistorySubject = BehaviorSubject.seeded([]);
    _upcomingSongsSubject = BehaviorSubject.seeded([]);
  }

  @override
  Future<void> dispose() async {
    await Future.wait([
      _currentSongSubject.close(),
      _listenHistorySubject.close(),
      _upcomingSongsSubject.close(),
    ]);
    await super.dispose();
  }

  Future<void> reset() async {
    await stop();
    songList.clear();
    _currentSongSubject.add(currentSong = null);
    _listenHistorySubject.add(listenHistory..clear());
    _upcomingSongsSubject.add(upcomingSongs..clear());
  }

  Future<void> ready(
    SongModel song,
    AudioSource audioSource, {
    required bool isPlaylist,
  }) async {
    songList = [song];
    _currentSongSubject.add(currentSong = song);
    _listenHistorySubject.add(listenHistory = [0]);
    _upcomingSongsSubject.add(upcomingSongs = []);

    if (!isPlaylist) {
      await setAudioSource(audioSource);
      await setLoopMode(LoopMode.off);
    } else {
      await setAudioSources([audioSource]);
      await setLoopMode(LoopMode.all);
    }
  }

  List<int>? _refreshUpcomingSongs() {
    _upcomingSongsSubject.add(
      upcomingSongs = [
        for (int index in effectiveIndices)
          if (!listenHistory.contains(index)) index,
      ],
    );
    return upcomingSongs;
  }

  int getIndexOf(String songId) {
    return songList.indexWhere((song) => song.id == songId);
  }

  Future<void> addSong(SongModel song, AudioSource audioSource) async {
    songList.add(song);
    _refreshUpcomingSongs();
    await super.addAudioSource(audioSource);
  }

  int? _getRelativeIndex(int offset) {
    offset = (offset + listenHistory.length - 1) % songList.length;
    if (offset < listenHistory.length) return listenHistory[offset];
    return upcomingSongs[offset - listenHistory.length];
  }

  void _updateHistory(int index) {
    if (index == currentIndex!) return;

    int k = listenHistory.indexOf(index);
    if (k != -1) {
      upcomingSongs.insertAll(0, listenHistory.sublist(k + 1));
      listenHistory = listenHistory.sublist(0, k + 1);
    } else {
      k = upcomingSongs.indexOf(index);
      assert(k != -1);
      listenHistory.addAll(upcomingSongs.sublist(0, k + 1));
      upcomingSongs = upcomingSongs.sublist(k + 1);
    }
    _listenHistorySubject.add(listenHistory);
    _upcomingSongsSubject.add(upcomingSongs);
    _currentSongSubject.add(currentSong = songList[index]);
  }

  @override
  Future<void> seek(Duration? position, {int? index}) async {
    if (index != null) _updateHistory(index);
    await super.seek(position, index: index);
  }

  @override
  Future<void> seekToNext() {
    return seek(Duration.zero, index: _getRelativeIndex(1));
  }

  @override
  Future<void> seekToPrevious() {
    return seek(Duration.zero, index: _getRelativeIndex(-1));
  }

  final _speeds = [1.0, 1.2, 1.5, 2.0, 0.5, 0.8];

  Future<void> toggleSongSpeed() async {
    final i = _speeds.indexOf(speed);
    await setSpeed(_speeds[(i + 1) % _speeds.length]);
  }

  Future<void> toggleShuffleMode() async {
    await setShuffleModeEnabled(!shuffleModeEnabled);
    _refreshUpcomingSongs();
  }

  Future<void> playOrPause() => playing ? pause() : play();
}
