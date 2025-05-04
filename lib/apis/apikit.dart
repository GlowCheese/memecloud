import 'dart:io';
import 'dart:async';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/apis/storage.dart';
import 'package:memecloud/models/artist_model.dart';
import 'package:memecloud/models/playlist_model.dart';
import 'package:memecloud/models/song_lyrics_model.dart';
import 'package:memecloud/utils/common.dart';
import 'package:memecloud/apis/connectivity.dart';
import 'package:memecloud/apis/supabase/main.dart';
import 'package:memecloud/models/song_model.dart';
import 'package:memecloud/models/user_model.dart';
import 'package:memecloud/apis/zingmp3/endpoints.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:memecloud/models/search_result_model.dart';
import 'package:memecloud/components/default_future_builder.dart';

class ApiKit {
  final dio = getIt<Dio>();
  final zingMp3 = getIt<ZingMp3Api>();
  final supabase = getIt<SupabaseApi>();
  final storage = getIt<PersistentStorage>();
  final _connectivity = getIt<ConnectivityStatus>();
  late final SupabaseClient client = supabase.client;

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

  Future<void> updateCached(String api, Map data) {
    return Future.wait([
      storage.updateCached(api, data),
      client.from('api_cache').upsert({'api': api, 'data': data}),
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
        unawaited(updateCached(api, cacheEncode!(data)));
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
      unawaited(storage.updateCached(api, remoteResp.toJson<SupabaseApi>()));
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

  Future<bool> getIsLiked(String songId) => supabase.songs.getIsLiked(songId);
  Future<void> setIsLiked(String songId, bool isLiked) =>
      supabase.songs.setIsLiked(songId, isLiked);
  Future<List<SongModel>> getLikedSongsList() =>
      supabase.songs.getLikedSongsList();

  /* ----------------------
  |    VIP SONGS FILTER   |
  ---------------------- */

  Future<bool> isNonVipSong(String songId) async {
    bool? cached = storage.isNonVipSong(songId);
    if (cached != null) return cached;
    bool res = (await filterNonVipSongs([songId])).contains(songId);
    if (!res) unawaited(storage.markSongAsVip(songId));
    return res;
  }

  Future<void> markSongAsVip(String songId) {
    return Future.wait([
      storage.markSongAsVip(songId),
      supabase.songs.markSongAsVip(songId),
    ]);
  }

  Future<List<String>> filterNonVipSongs(List<String> songsIds) async {
    try {
      return await supabase.songs.filterNonVipSongs(songsIds);
    } on ConnectionLoss {
      return songsIds.where((e) => storage.isNonVipSong(e) == true).toList();
    }
  }

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

  /* --------------------
  |    SEARCHES APIs    |
  -------------------- */

  void saveSearch(String query) => storage.saveSearch(query);
  void removeSearch(String query) => storage.saveSearch(query, negate: true);
  List<String> getRecentSearches() => storage.getRecentSearches();

  Future<List<SongModel>?> searchSongs(String keyword, {required int page}) async {
    final jsons = await zingMp3.searchSongs(keyword, page: page);
    return jsons == null ? null : SongModel.fromListJson<ZingMp3Api>(jsons);
  }

  Future<List<PlaylistModel>?> searchPlaylists(String keyword, {required int page}) async {
    final jsons = await zingMp3.searchPlaylists(keyword, page: page);
    return jsons == null ? null : PlaylistModel.fromListJson<ZingMp3Api>(jsons);
  }

  Future<List<ArtistModel>?> searchArtists(String keyword, {required int page}) async {
    final jsons = await zingMp3.searchArtists(keyword, page: page);
    return jsons == null ? null : ArtistModel.fromListJson<ZingMp3Api>(jsons);
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

  /// Return `null` if `isNonVipSong(songId) == false`, \
  /// otherwise the local path for the song file. \
  /// May requires download the file from remote, or ZingMp3API.
  Future<String?> getSongPath(String songId) async {
    final fileName = '$songId.mp3';
    late Directory dir;
    late String filePath;
    late File file;
    final bucket = 'songs';

    for (dir in [storage.userDir, storage.cacheDir]) {
      file = File(filePath = '${dir.path}/$fileName');
      if (await file.exists()) return filePath;
    }

    if (!await isNonVipSong(songId)) return null;
    var bytes = await supabase.cache.getFile(bucket, fileName);
    if (bytes == null) {
      final songUrl = await zingMp3.fetchSongUrl(songId);
      if (songUrl == null) {
        unawaited(markSongAsVip(songId));
        return null;
      }
      await _downloadFile(songUrl, filePath);

      bytes = await file.readAsBytes();
      unawaited(supabase.cache.uploadFile(bucket, fileName, bytes));
    } else {
      await file.writeAsBytes(bytes);
    }

    return filePath;
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
      Future<List<Map<String, dynamic>>>
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

  /* ---------------------
  |    MISCELLANEOUS     |
  --------------------- */

  Widget paletteColorsWidgetBuider(
    String imageUrl,
    Widget Function(List<Color> paletteColors) func,
  ) {
    final paletteColors = storage.getPaletteColors(imageUrl);
    if (paletteColors != null) return func(paletteColors);

    return defaultFutureBuilder(
      future: getPaletteColors(imageUrl),
      onData: (context, data) {
        final paletteColors = data;
        unawaited(storage.setPaletteColors(imageUrl, paletteColors));
        return func(paletteColors);
      },
    );
  }
}

Future<List<Map<String, dynamic>>> _getSongsForHomeOutputFixer(
  List<Map<String, dynamic>> data,
) async {
  for (var songList in data) {
    final items = songList['items'];
    var songIds = List<String>.from(items.map((song) => song['encodeId']));

    songIds = await getIt<ApiKit>().filterNonVipSongs(songIds);
    songList['items'] =
        items
            .where((song) => songIds.contains(song['encodeId']))
            .map((song) => SongModel.fromJson<ZingMp3Api>(song))
            .toList();
  }
  return data;
}
