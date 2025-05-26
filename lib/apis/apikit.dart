import 'dart:io';
import 'dart:async';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:memecloud/apis/firebase/main.dart';
import 'package:memecloud/apis/others/events.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/utils/common.dart';
import 'package:memecloud/models/song_model.dart';
import 'package:memecloud/models/user_model.dart';
import 'package:memecloud/apis/supabase/main.dart';
import 'package:memecloud/apis/others/storage.dart';
import 'package:memecloud/models/artist_model.dart';
import 'package:memecloud/models/playlist_model.dart';
import 'package:memecloud/apis/zingmp3/endpoints.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:memecloud/models/week_chart_model.dart';
import 'package:memecloud/apis/others/connectivity.dart';
import 'package:memecloud/models/song_lyrics_model.dart';
import 'package:memecloud/models/search_result_model.dart';
import 'package:memecloud/models/search_suggestion_model.dart';

class ApiKit {
  final dio = getIt<Dio>();
  final zingMp3 = getIt<ZingMp3Api>();
  final supabase = getIt<SupabaseApi>();
  final storage = getIt<PersistentStorage>();
  final _connectivity = getIt<ConnectivityStatus>();

  late final SupabaseClient client;
  late final SupabaseEvents events;

  ApiKit() {
    client = supabase.client;
    events = SupabaseEvents(this);
  }

  /* ---------------------
  |    AUTHENTICATION    |
  --------------------- */

  User? currentUser() => supabase.auth.currentUser();
  Session? currentSession() => supabase.auth.currentSession();
  Future<User> signIn({required String email, required String password}) =>
      supabase.auth.signIn(email, password);
  Future<User> signUp({
    required String email,
    required String password,
    required String fullName,
  }) => supabase.auth.signUp(email, password, fullName);
  Future<void> signOut() => supabase.auth.signOut();

  /* -----------------------
  |    API CACHE SYSTEM    |
  ----------------------- */

  Future<CachedDataWithFallback<Map>> _getCachedApi(
    String api, {
    int? lazyTime,
  }) async {
    final localResp = storage.getCached<Map>(api, lazyTime: lazyTime);
    if (localResp.data != null) {
      debugPrint("Found local cache for $api!");
      return localResp;
    }

    final remoteResp = await supabase.cache.getCached(api, lazyTime: lazyTime);
    if (remoteResp.data != null) {
      unawaited(storage.updateCached(api, remoteResp.data!));
      return remoteResp;
    }

    return remoteResp;
  }

  Future<void> _updateCached(String api, Map data) {
    return Future.wait([
      storage.updateCached(api, data),
      client.from('api_cache').upsert({
        'api': api,
        'data': data,
        'created_at': DateTime.now().toIso8601String(),
      }),
    ]);
  }

  Future<Output> _getOrFetch<DataType, Output>(
    String api, {
    int? lazyTime,
    required Future<DataType> Function() fetchFunc,
    DataType Function(Map json)? cacheDecode,
    Map Function(DataType data)? cacheEncode,
    Output Function(DataType data)? outputFixer,
  }) async {
    cacheDecode ??= (x) => x as DataType;
    cacheEncode ??= (x) => x as Map; // supposing x is a Map
    outputFixer ??= (x) => x as Output; // return raw json data

    final cached = await _getCachedApi(api, lazyTime: lazyTime);
    return cached.fold((data) => outputFixer!(cacheDecode!(data)), (
      fallback,
    ) async {
      try {
        final data = await fetchFunc();
        unawaited(_updateCached(api, cacheEncode!(data)));
        return outputFixer!(data);
      } catch (_) {
        if (fallback != null) {
          return outputFixer!(cacheDecode!(fallback));
        }
        rethrow;
      }
    });
  }

  /* -------------------
  |    PROFILE APIs    |
  ------------------- */

  UserModel myProfile() => supabase.profile.myProfile!;
  Future<UserModel?> getProfile({String? userId}) =>
      supabase.profile.getProfile(userId);
  Future<void> changeName(String newName) async =>
      await supabase.profile.changeName(newName);
  Future<String?> setAvatar(File file) async =>
      await supabase.profile.setAvatar(file);
  Future<void> unsetAvatar() => supabase.profile.unsetAvatar();

  /* ----------------
  |    SONGS APIs   |
  ---------------- */

  Future<void> saveSongInfo(SongModel song) async {
    if (storage.isInfoSaved(song.id, 'song')) return;
    await supabase.songs.saveSongInfo(song);
    await supabase.artists.saveSongArtists(song.id, song.artists);
    unawaited(storage.markInfoAsSaved(song.id, 'song'));
  }

  Future<void> newSongStream(SongModel song) {
    return Future.wait([
      supabase.songs.newSongStream(song.id),
      ...song.artists.map((e) => supabase.artists.newArtistStream(e.id)),
    ]);
  }

  Future<int> songStreamCount(String songId) {
    return supabase.songs.streamCount(songId);
  }

  /* ---------------------
  |    PLAYLISTS APIs    |
  -------------------- */

  Future<void> savePlaylistInfo(PlaylistModel playlist) async {
    if (storage.isInfoSaved(playlist.id, 'playlist')) return;
    await supabase.playlists.savePlaylistInfo(playlist);
    unawaited(storage.markInfoAsSaved(playlist.id, 'playlist'));
  }

  Future<PlaylistModel?> getPlaylistInfo(String playlistId) async {
    final String api = '/infoplaylist?id=$playlistId';
    return await _getOrFetch<Map<String, dynamic>?, PlaylistModel?>(
      api,
      fetchFunc: () => zingMp3.fetchPlaylistInfo(playlistId),
      cacheEncode: (data) => ignoreNullValuesOfMap({'data': data}),
      cacheDecode: (json) {
        if (!json.containsKey('data')) return null;
        return Map.castFrom<dynamic, dynamic, String, dynamic>(json['data']);
      },
      outputFixer: (data) {
        if (data == null) return null;
        final res = PlaylistModel.fromJson<ZingMp3Api>(data);
        unawaited(savePlaylistInfo(res));
        return res;
      },
    );
  }

  /* --------------------
  |    DOWNLOAD APIs    |
  -------------------- */

  Future<void> _downloadFile(
    String url,
    String savePath, {
    void Function(int received, int total)? onProgress,
  }) async {
    try {
      _connectivity.ensure();
      await dio.download(url, savePath, onReceiveProgress: onProgress);
    } catch (e, stackTrace) {
      _connectivity.reportCrash(e, StackTrace.current);
      log('Failed to download file: $e', stackTrace: stackTrace, level: 1000);
      rethrow;
    }
  }

  Future<void> downloadSong(
    String songId,
    String songUri, {
    void Function(int received, int total)? onProgress,
  }) async {
    final filePath = '${storage.userDir.path}/$songId.mp3';
    await _downloadFile(songUri, filePath, onProgress: onProgress);
    await markSongAsDownloaded(songId);
  }

  Future<void> undownloadSong(String songId) async {
    final filePath = '${storage.userDir.path}/$songId.mp3';
    await File(filePath).delete();
    return storage.undownloadSong(songId);
  }

  bool isSongDownloaded(String songId) {
    return storage.isSongDownloaded(songId);
  }

  Future<void> markSongAsDownloaded(String songId) {
    return storage.markSongAsDownloaded(songId);
  }

  /* ---------------------
  |    ARTISTS APIs    |
  -------------------- */

  Future<ArtistModel?> getArtistInfo(String artistAlias) async {
    final String api = '/infoartist?alias=$artistAlias';
    return await _getOrFetch<Map<String, dynamic>?, ArtistModel?>(
      api,
      fetchFunc: () => zingMp3.fetchArtistInfo(artistAlias),
      cacheEncode: (data) => ignoreNullValuesOfMap({'data': data}),
      cacheDecode: (json) {
        if (!json.containsKey('data')) return null;
        return Map.castFrom<dynamic, dynamic, String, dynamic>(json['data']);
      },
      outputFixer: (data) {
        if (data == null) return null;
        return ArtistModel.fromJson<ZingMp3Api>(data);
      },
    );
  }

  Future<List<ArtistModel>> getTopArtists({required int count}) {
    return supabase.artists.getTopArtists(count: count);
  }

  Future<int> getArtistFollowersCount(String artistId) {
    return supabase.artists.getArtistFollowersCount(artistId);
  }

  Future<bool> isFollowingArtist(String artistId) {
    return supabase.artists.isFollowingArtist(artistId);
  }

  Future<void> toggleFollowArtist(String artistId) {
    return supabase.artists.toggleFollowArtist(artistId);
  }

  Future<int> artistStreamCount(String artistId) {
    return supabase.artists.streamCount(artistId);
  }

  /* ----------------------
  |    LIKEs & FOLLOWs    |
  ---------------------- */

  bool isSongLiked(String songId) {
    return storage.isSongLiked(songId);
  }

  Future setIsSongLiked(SongModel song, bool isLiked) {
    unawaited(supabase.songs.setIsLiked(song.id, isLiked));
    return storage.setIsLiked(song, isLiked);
  }

  List<SongModel> getLikedSongs() {
    return storage.getLikedSongs();
  }

  /* --------------------
  |    BLACKLIST APIs   |
  -------------------- */

  bool isBlacklisted(String songId) {
    return storage.isSongBlacklisted(songId);
  }

  Future setIsBlacklisted(SongModel song, bool isBlacklisted) {
    unawaited(supabase.songs.setIsBlacklisted(song.id, isBlacklisted));
    return storage.setIsBlacklisted(song, isBlacklisted);
  }

  List<SongModel> getBlacklistedSongs() {
    return storage.getBlacklistedSongs();
  }

  Iterable<String> filterNonBlacklistedSongs(Iterable<String> songIds) {
    return storage.filterNonBlacklistedSongs(songIds);
  }

  /* ----------------------
  |    VIP SONGS FILTER   |
  ---------------------- */

  bool isNonVipSong(String songId) {
    return storage.isNonVipSong(songId);
  }

  Future<void> markSongAsVip(String songId) {
    return Future.wait([
      storage.markSongAsVip(songId),
      supabase.songs.markSongAsVip(songId),
    ]);
  }

  Iterable<String> filterNonVipSongs(Iterable<String> songIds) {
    return storage.filterNonVipSongs(songIds);
  }

  /* ------------------
  |    SEARCH APIs    |
  ------------------ */

  void saveRecentSearch(String query) => storage.saveSearch(query);
  void removeRecentSearch(String query) =>
      storage.saveSearch(query, negate: true);
  Iterable<String> getRecentSearches() => storage.getRecentSearches();

  Future<List<SongModel>?> searchSongs(
    String keyword, {
    required int page,
  }) async {
    final jsons = await zingMp3.searchSongs(keyword, page: page);
    if (jsons == null) return null;
    return SongModel.fromListJson<ZingMp3Api>(jsons);
  }

  Future<List<PlaylistModel>?> searchPlaylists(
    String keyword, {
    required int page,
  }) async {
    final jsons = await zingMp3.searchPlaylists(keyword, page: page);
    if (jsons == null) return null;
    return PlaylistModel.fromListJson<ZingMp3Api>(jsons);
  }

  Future<List<ArtistModel>?> searchArtists(
    String keyword, {
    required int page,
  }) async {
    final jsons = await zingMp3.searchArtists(keyword, page: page);
    if (jsons == null) return null;
    return ArtistModel.fromListJson<ZingMp3Api>(jsons);
  }

  Future<SearchSuggestionModel?> getSearchSuggestions(String keyword) async {
    final items = await zingMp3.fetchSearchSuggestions(keyword);
    if (items == null) return null;
    return await SearchSuggestionModel.fromList<ZingMp3Api>(items);
  }

  Future<SearchResultModel> searchMulti(String keyword) async {
    keyword = normalizeSearchQueryString(keyword);

    String api = '/search?keyword=$keyword';
    final int lazyTime = 14 * 24 * 60 * 60; // 14 days

    return await _getOrFetch<Map, SearchResultModel>(
      api,
      lazyTime: lazyTime,
      fetchFunc: () => zingMp3.searchMulti(keyword),
      outputFixer: (data) => SearchResultModel.fromJson(data),
    );
  }

  /* ----------------------
  |    WEEK CHART APIs    |
  ---------------------- */

  Future<WeekChartModel> getVpopWeekChart() async {
    return WeekChartModel.fromJson<ZingMp3Api>(
      "Việt Nam",
      await zingMp3.fetchVpopWeekChart(),
    );
  }

  Future<WeekChartModel> getUsukWeekChart() async {
    return WeekChartModel.fromJson<ZingMp3Api>(
      "Âu Mĩ",
      await zingMp3.fetchUsukWeekChart(),
    );
  }

  Future<WeekChartModel> getKpopWeekChart() async {
    return WeekChartModel.fromJson<ZingMp3Api>(
      "Hàn Quốc",
      await zingMp3.fetchKpopWeekChart(),
    );
  }

  /* ----------------------
  |    STORAGE & CACHE    |
  ---------------------- */

  /// Return `null` if `isNonVipSong(songId) == false`, \
  /// otherwise the Uri for the song (either remote or local).
  Future<Uri?> getSongUri(String songId) async {
    final fileName = '$songId.mp3';
    final dir = storage.userDir;
    final filePath = '${dir.path}/$fileName';
    final file = File(filePath);

    if (await file.exists()) return Uri.file(filePath);
    if (isBlacklisted(songId)) return null;

    final api = '/song_url?id=$songId';
    return storage.getCached<String>(api).fold<Future<Uri>>(
      (url) async => Uri.parse(url),
      (_) async {
        String? url = await FirebaseApi.getSongUrl(songId);
        if (url == null) {
          url = await zingMp3.fetchSongUrl(songId);
          await FirebaseApi.uploadSongFromUrl(url, songId);
        }
        storage.updateCached(api, url);
        return Uri.parse(url);
      }
    );
  }

  Future<SongLyricsModel?> getSongLyric(String songId) async {
    final fileName = '$songId.lrc';
    final dir = storage.cacheDir;
    final filePath = '${dir.path}/$fileName';
    final file = File(filePath);
    final bucket = 'lyrics';

    if (await file.exists()) {
      return SongLyricsModel.parse(file);
    }

    var bytes = await supabase.cache.getFile(bucket, fileName);
    if (bytes == null) {
      final lyricMap = await zingMp3.fetchLyric(songId);
      if (!lyricMap.containsKey('file')) {
        if (!lyricMap.containsKey('lyric')) {
          return null;
        } else {
          return SongLyricsModel.noTimeLine(lyricMap['lyric']);
        }
      }
      await _downloadFile(lyricMap['file'], filePath);

      bytes = await file.readAsBytes();
      unawaited(supabase.cache.uploadFile(bucket, fileName, bytes));
    } else {
      await file.writeAsBytes(bytes);
    }

    return SongLyricsModel.parse(file);
  }

  /* -----------------
  |    COOKIE APIs   |
  ----------------- */

  String getZingCookieStr() {
    return storage.getZingCookie<String>()!;
  }

  Map<String, String> getZingCookieMap() {
    return storage.getZingCookie<Map<String, String>>()!;
  }

  Future<void> updateZingCookie(List<String> cookies) async {
    final newCookieStr = await storage.updateCookie(cookies);
    unawaited(supabase.config.setCookie(newCookieStr));
  }

  Future<List<Map<String, dynamic>>> getSongsForHome() async {
    final String api = '/home';
    final int lazyTime = 12 * 60 * 60; // 12 hours

    return await _getOrFetch<
      List<Map<String, dynamic>>,
      List<Map<String, dynamic>>
    >(
      api,
      lazyTime: lazyTime,
      fetchFunc: zingMp3.fetchHome,
      cacheDecode:
          (json) => List.castFrom<dynamic, Map<String, dynamic>>(json['items']),
      cacheEncode: (data) => {'items': data},
      outputFixer: (data) => _getSongsForHomeOutputFixer(data),
    );
  }

  /* -------------------
  |    MISCELLANEOUS   |
  ------------------- */

  Iterable<String> filterPlayableSongs(Iterable<String> songIds) {
    songIds = filterNonBlacklistedSongs(songIds);
    return songIds;
  }
}

List<Map<String, dynamic>> _getSongsForHomeOutputFixer(
  List<Map<String, dynamic>> data,
) {
  for (var songList in data) {
    final items = songList['items'];
    var songIds = List<String>.from(items.map((song) => song['encodeId']));

    songIds = getIt<ApiKit>().filterPlayableSongs(songIds).toList();
    songList['items'] =
        List.castFrom<dynamic, Map<String, dynamic>>(items)
            .where((song) => songIds.contains(song['encodeId']))
            .map((song) => SongModel.fromJson<ZingMp3Api>(song))
            .toList();
  }
  return data;
}
