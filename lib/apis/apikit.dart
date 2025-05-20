import 'dart:io';
import 'dart:async';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
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

  late final SupabaseClient client = supabase.client;
  late final events = SupabaseEvents(client: client);

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
    if (storage.isSongInfoSaved(song.id)) {
      debugPrint("Song info of '${song.id}' already marked as saved!");
      return;
    }
    await supabase.songs.saveSongInfo(song);
    await supabase.artists.saveSongArtists(song.id, song.artists);
    unawaited(storage.markSongInfoAsSaved(song.id));
  }

  Future<SongModel?> getSongInfo(String songId) async {
    String api = '/infosong?id=$songId';
    final localResp = storage.getCached(api);
    if (localResp.data != null) {
      return SongModel.fromJson<SupabaseApi>(localResp.data!);
    }

    final remoteResp = await supabase.songs.getSongInfo(songId);
    if (remoteResp != null) {
      unawaited(storage.updateCached(api, remoteResp.toJson()));
      return remoteResp;
    }

    final zingResp = await getIt<ZingMp3Api>().fetchSongInfo(songId);
    if (zingResp != null) {
      unawaited(storage.updateCached(api, zingResp));
      final song = SongModel.fromJson<ZingMp3Api>(zingResp);
      unawaited(saveSongInfo(song));
      return song;
    }

    return null;
  }

  Future<bool> isBlacklisted(String songId) =>
      supabase.songs.isBlacklisted(songId);
  Future<void> toggleBlacklist(String songId) =>
      supabase.songs.toggleBlacklist(songId);
  Future<List<SongModel>> getBlacklistedSongs() =>
      supabase.songs.getBlacklistSongs();

  /* --------------------
  |    PLAYLISTS AND    |
  |     ARTISTS APIs    |
  -------------------- */

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
        return PlaylistModel.fromJson<ZingMp3Api>(data);
      },
    );
  }

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

  Future<List<ArtistModel>> getTopArtists(int count) {
    return getIt<SupabaseApi>().artists.getTopArtists(count);
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

  /* ---------------------
  |    SUPABASE CACHE    |
  |     AND STORAGE      |
  --------------------- */

  Future<void> _downloadFile(String url, String savePath) async {
    try {
      _connectivity.ensure();
      await dio.download(url, savePath);
    } catch (e, stackTrace) {
      _connectivity.reportCrash(e, StackTrace.current);
      log('Failed to download song: $e', stackTrace: stackTrace, level: 1000);
      rethrow;
    }
  }

  bool isSongUriActive(Uri uri) {
    final authen = uri.queryParameters['authen'];
    final expStr = authen
        ?.split('~')
        .firstWhere((e) => e.startsWith('exp='), orElse: () => '')
        .split('=')
        .elementAtOrNull(1);

    final exp = int.tryParse(expStr ?? '') ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return exp > now + 600;
  }

  /// Return `null` if `isNonVipSong(songId) == false`, \
  /// otherwise the Uri for the song (either remote or local).
  Future<Uri?> getSongUri(String songId) async {
    final fileName = '$songId.mp3';
    final dir = storage.userDir;
    final filePath = '${dir.path}/$fileName';
    final file = File(filePath);

    if (await file.exists()) return Uri.file(filePath);
    if (!isNonVipSong(songId)) return null;

    final api = '/songuri?id=$songId';
    late Uri? uri;

    for (var i = 0; i < 2; i++) {
      uri = await _getOrFetch<String?, Uri?>(
        api,
        lazyTime: i == 0 ? null : 0,
        fetchFunc: () => zingMp3.fetchSongUrl(songId),
        cacheEncode: (data) => {'uri': data},
        cacheDecode: (json) => json['uri'],
        outputFixer: (data) {
          if (data == null) return null;
          return Uri.parse(data);
        },
      );
      if (uri == null) {
        unawaited(markSongAsVip(songId));
        return null;
      }
      if (isSongUriActive(uri)) return uri;
    }
    return null;
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
}

List<Map<String, dynamic>> _getSongsForHomeOutputFixer(
  List<Map<String, dynamic>> data,
) {
  for (var songList in data) {
    final items = songList['items'];
    var songIds = List<String>.from(items.map((song) => song['encodeId']));

    songIds = getIt<ApiKit>().filterNonVipSongs(songIds).toList();
    songList['items'] =
        List.castFrom<dynamic, Map<String, dynamic>>(items)
            .where((song) => songIds.contains(song['encodeId']))
            .map((song) => SongModel.fromJson<ZingMp3Api>(song))
            .toList();
  }
  return data;
}
