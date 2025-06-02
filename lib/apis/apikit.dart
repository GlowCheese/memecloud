import 'dart:io';
import 'dart:async';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/utils/common.dart';
import 'package:memecloud/models/song_model.dart';
import 'package:memecloud/models/user_model.dart';
import 'package:memecloud/apis/others/events.dart';
import 'package:memecloud/apis/firebase/main.dart';
import 'package:memecloud/apis/supabase/main.dart';
import 'package:memecloud/apis/others/storage.dart';
import 'package:memecloud/models/artist_model.dart';
import 'package:memecloud/models/playlist_model.dart';
import 'package:memecloud/apis/zingmp3/endpoints.dart';
import 'package:memecloud/utils/noti.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:memecloud/models/week_chart_model.dart';
import 'package:memecloud/apis/others/connectivity.dart';
import 'package:memecloud/models/song_lyrics_model.dart';
import 'package:memecloud/models/search_result_model.dart';
import 'package:memecloud/models/search_suggestion_model.dart';
import 'package:memecloud/blocs/dl_status/dl_status_manager.dart';
import 'package:memecloud/blocs/recent_played/recent_played_stream.dart';

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
  Future<User> signIn({required String email, required String password}) async {
    final user = await supabase.auth.signIn(email, password);
    await getIt<SupabaseEvents>().loadUserData();
    return user;
  }

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
      supabase.cache.updateCached(api, data),
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
    if (storage.getCachedSong(song.id) == null) {
      await supabase.songs.saveSongInfo(song);
      await supabase.artists.saveSongArtists(song.id, song.artists);

      String api = '/infosong?id=${song.id}';
      await storage.updateCached(api, song.toJson());
    }
  }

  Future<void> newSongStream(SongModel song) {
    getIt<RecentPlayedStream>().addSong(song);
    return Future.wait([
      supabase.songs.newSongStream(song.id),
      ...song.artists.map((e) => supabase.artists.newArtistStream(e.id)),
      storage.saveRecentlyPlayedSong(song),
    ]);
  }

  Future<int> songStreamCount(String songId) {
    return supabase.songs.streamCount(songId);
  }

  /* ---------------------
  |    PLAYLISTS APIs    |
  -------------------- */

  Future<void> savePlaylistInfo(PlaylistModel playlist) async {
    await supabase.playlists.savePlaylistInfo(playlist);
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

  /* ---------------------
  |    RECENTLY PLAYED   |
  |    SONGS/PLAYLISTS   |
  --------------------- */

  Iterable<SongModel> getRecentlyPlayedSongs() {
    return storage.getRecentlyPlayedSongs();
  }

  Iterable<PlaylistModel> getRecentlyPlayedPlaylists() {
    return storage.getRecentlyPlayedPlaylists();
  }

  Future<void> saveRecentlyPlayedPlaylist(PlaylistModel playlist) async {
    getIt<RecentPlayedStream>().addPlaylist(playlist);
    await storage.saveRecentlyPlayedPlaylist(playlist);
  }

  /* -------------------------
  |    SONG DOWNLOAD APIs    |
  ------------------------- */

  Future<bool> _downloadFile(
    String url,
    String savePath, {
    CancelToken? cancelToken,
    void Function(int received, int total)? onProgress,
  }) async {
    // throttle progress updates
    var lastProgressTime = DateTime.now();

    void realOnProgress(int received, int total) {
      final now = DateTime.now();
      if (now.difference(lastProgressTime).inMilliseconds >= 800) {
        lastProgressTime = now;
        onProgress?.call(received, total);
      }
    }

    try {
      _connectivity.ensure();
      await dio.download(
        url,
        savePath,
        cancelToken: cancelToken,
        onReceiveProgress: realOnProgress,
      );
      return true;
    } on DioException catch (e, stackTrace) {
      if (e.type == DioExceptionType.cancel) {
        // TODO: Download was cancelled, but onProgress might still be running...
        await Future.delayed(const Duration(milliseconds: 100));
        log('Download cancelled.', stackTrace: stackTrace);
        return false;
      } else {
        _connectivity.reportCrash(e, StackTrace.current);
        log('Failed to download file: $e', stackTrace: stackTrace, level: 1000);
        rethrow;
      }
    } catch (e, stackTrace) {
      _connectivity.reportCrash(e, StackTrace.current);
      log('Failed to download file: $e', stackTrace: stackTrace, level: 1000);
      rethrow;
    }
  }

  Future<Map<String, String>?> getSongUrlsForDownload(String songId) async {
    getIt<SongDlStatusManager>().updateState(songId, isFetching: true);
    try {
      return await zingMp3.fetchSongUrls(songId);
    } catch (_) {
      await getIt<SongDlStatusManager>().cancelDownload(songId);
      return null;
    }
  }

  Future<String?> getSongUrlForDownload(
    String songId, {
    String quality = "320",
  }) async {
    // doing this because firebase store 320kbps songs by default
    if (quality == "320") {
      final uri = await getSongUri(songId);
      return uri.toString();
    }

    final urls = await getSongUrlsForDownload(songId);
    if (urls == null) return null;

    if (urls.containsKey(quality) == true) return urls[quality]!;
    return urls.values.last; // TODO: random one?
  }

  Future<bool> downloadSong(
    SongModel song,
    String songUrl, {
    bool sendNoti = true,
    CancelToken? cancelToken,
    void Function(int received, int total)? onProgress,
  }) async {
    final filePath = '${storage.downloadDir.path}/${song.id}.mp3';

    cancelToken ??= CancelToken();
    void realOnProgress(int received, int total) {
      getIt<SongDlStatusManager>().updateProgress(song.id, received / total);
      onProgress?.call(received, total);
      if (sendNoti) {
        sendProgressNoti(
          id: song.id.hashCode,
          progress: ((received / total) * 100).round(),
          title: 'Đang tải xuống bài hát: ${song.title}',
        );
      }
    }

    final downloadTask = CancelableOperation.fromFuture(
      _downloadFile(
            songUrl,
            filePath,
            onProgress: realOnProgress,
            cancelToken: cancelToken,
          )
          .then((success) async {
            if (success) {
              _markSongAsDownloaded(song);
              if (sendNoti) {
                sendCompleteNoti(
                  id: song.id.hashCode,
                  body: 'Bài hát: ${song.title}',
                  title: 'Tải xuống bài hát thành công!',
                );
              }
            } else {
              _markSongAsNotDownloaded(song.id);
            }
            return success;
          })
          .catchError((e) {
            sendErrorNoti(
              id: song.id.hashCode,
              title: 'Lỗi khi tải bài hát!',
              error: e,
            );
            _markSongAsNotDownloaded(song.id);
            return false;
          }),
      onCancel: () => cancelToken!.cancel(),
    );
    getIt<SongDlStatusManager>().updateState(
      song.id,
      downloadTask: downloadTask,
    );

    return await downloadTask.valueOrCancellation() == true;
  }

  Future<void> undownloadSong(String songId) async {
    if (storage.isSongDownloaded(songId)) {
      final filePath = '${storage.downloadDir.path}/$songId.mp3';
      await File(filePath).delete();
      _markSongAsNotDownloaded(songId);
    }
  }

  bool isSongDownloaded(String songId) {
    return storage.isSongDownloaded(songId);
  }

  List<SongModel> getDownloadedSongs() => storage.getDownloadedSongs();

  Future<void> _markSongAsNotDownloaded(String songId) async {
    await storage.markSongAsNotDownloaded(songId);
    await getIt<SongDlStatusManager>().cancelDownload(songId);
  }

  Future<void> _markSongAsDownloaded(SongModel song) async {
    await storage.markSongAsDownloaded(song);
    getIt<SongDlStatusManager>().updateState(song.id, isCompleted: true);
  }

  /* -----------------------------
  |    PLAYLIST DOWNLOAD APIs    |
  ----------------------------- */

  bool isPlaylistDownloaded(String playlistId) {
    return storage.isPlaylistDownloaded(playlistId);
  }

  List<PlaylistModel> getDownloadedPlaylists() {
    return storage.getDownloadedPlaylists();
  }

  List<SongModel> getUndownloadedSongsInPlaylist(PlaylistModel playlist) {
    getIt<PlaylistDlStatusManager>().updateState(playlist.id, isFetching: true);
    final res =
        playlist.songs!.where((song) => !isSongDownloaded(song.id)).toList();
    return res;
  }

  Future<bool> downloadPlaylist(
    String playlistId,
    String playlistTitle,
    List<SongModel> songs,
    String quality,
  ) async {
    final cancelToken = CancelToken();

    Future<bool> downloadProcess() async {
      final songDlManager = getIt<SongDlStatusManager>();

      List<String> songIds = [];
      for (var song in songs) {
        songDlManager.updateState(song.id, isFetching: true);
        songIds.add(song.id);
        if (cancelToken.isCancelled) {
          for (var songId in songIds) {
            songDlManager.cancelDownload(songId);
          }
          return false;
        }
      }
      songIds.clear();

      for (var song in songs) {
        if (cancelToken.isCancelled) {
          songDlManager.cancelDownload(song.id);
          continue;
        }
        final songUrl = await getSongUrlForDownload(song.id, quality: quality);
        if (songUrl != null) {
          void onProgress(int received, int total) {
            final songProgress = received / total;
            final playlistProgress =
                (songIds.length + songProgress) / songs.length;
            getIt<PlaylistDlStatusManager>().updateProgress(
              playlistId,
              playlistProgress,
            );
            sendProgressNoti(
              id: playlistId.hashCode,
              title: 'Đang tải xuống danh sách phát: $playlistTitle',
              progress: ((playlistProgress) * 100).round(),
            );
          }

          final success = await downloadSong(
            song,
            songUrl,
            sendNoti: false,
            cancelToken: cancelToken,
            onProgress: onProgress,
          );
          if (!success) {
            if (!cancelToken.isCancelled) cancelToken.cancel();
            continue;
          }
          songIds.add(song.id);
        }
      }

      if (!cancelToken.isCancelled) return true;

      for (var songId in songIds) {
        undownloadSong(songId);
      }
      return false;
    }

    final downloadTask = CancelableOperation.fromFuture(
      downloadProcess()
          .then((success) {
            if (success) {
              sendCompleteNoti(
                id: playlistId.hashCode,
                body: 'Danh sách phát: $playlistTitle',
                title: 'Tải xuống danh sách phát thành công!',
              );
              _markPlaylistAsDownloaded(playlistId);
            } else {
              _markPlaylistAsNotDownloaded(playlistId);
            }
            return success;
          })
          .catchError((e) {
            sendErrorNoti(
              id: playlistId.hashCode,
              title: 'Lỗi khi tải danh sách phát!',
              error: e,
            );
            _markPlaylistAsNotDownloaded(playlistId);
            return false;
          }),
      onCancel: () => cancelToken.cancel(),
    );
    getIt<PlaylistDlStatusManager>().updateState(
      playlistId,
      downloadTask: downloadTask,
    );

    return await downloadTask.valueOrCancellation() == true;
  }

  Future<void> undownloadPlaylist(String playlistId) async {
    if (storage.isPlaylistDownloaded(playlistId)) {
      final playlist = storage.getCachedPlaylist(playlistId)!;
      await Future.wait([
        for (var song in playlist.songs!) undownloadSong(song.id),
      ]);
      await _markPlaylistAsNotDownloaded(playlistId);
    }
  }

  Future<void> _markPlaylistAsNotDownloaded(String playlistId) async {
    await storage.markPlaylistAsNotDownloaded(playlistId);
    await getIt<PlaylistDlStatusManager>().cancelDownload(playlistId);
  }

  Future<void> _markPlaylistAsDownloaded(String playlistId) async {
    await storage.markPlaylistAsDownloaded(playlistId);
    getIt<PlaylistDlStatusManager>().updateState(playlistId, isCompleted: true);
  }

  /* -------------------
  |    ARTISTS APIs    |
  ------------------- */

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
    return storage.setSongIsLiked(song, isLiked);
  }

  List<SongModel> getLikedSongs() {
    return storage.getLikedSongs();
  }

  bool isPlaylistFollowed(String playlistId) {
    return storage.isPlaylistFollowed(playlistId);
  }

  Future setIsPlaylistFollowed(PlaylistModel playlist, bool isFollowed) {
    unawaited(supabase.playlists.setIsFollowed(playlist.id, isFollowed));
    return storage.setPlaylistIsFollowed(playlist, isFollowed);
  }

  List<PlaylistModel> getFollowedPlaylists() {
    return storage.getFollowedPlaylists();
  }

  Future<int> getPlaylistFollowerCounts(String playlistId) {
    return supabase.playlists.getPlaylistFollowerCounts(playlistId);
  }

  /* --------------------
  |    BLACKLIST APIs   |
  -------------------- */

  bool isBlacklisted(String songId) {
    return storage.isSongBlacklisted(songId);
  }

  Future<void> setIsBlacklisted(SongModel song, bool isBlacklisted) {
    unawaited(supabase.songs.setIsBlacklisted(song.id, isBlacklisted));
    return storage.setIsBlacklisted(song, isBlacklisted);
  }

  List<SongModel> getBlacklistedSongs() {
    return storage.getBlacklistedSongs();
  }

  Iterable<String> filterNonBlacklistedSongs(Iterable<String> songIds) {
    return storage.filterNonBlacklistedSongs(songIds);
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
    String api = '/vpop_week_chart';
    final int lazyTime = 24 * 60 * 60; // 1 day
    return _getOrFetch(
      api,
      lazyTime: lazyTime,
      fetchFunc: zingMp3.fetchVpopWeekChart,
      outputFixer: (data) {
        return WeekChartModel.fromJson<ZingMp3Api>("Việt Nam", data);
      },
    );
  }

  Future<WeekChartModel> getUsukWeekChart() async {
    String api = '/usuk_week_chart';
    final int lazyTime = 24 * 60 * 60; // 1 ngày
    return _getOrFetch(
      api,
      lazyTime: lazyTime,
      fetchFunc: zingMp3.fetchUsukWeekChart,
      outputFixer: (data) {
        return WeekChartModel.fromJson<ZingMp3Api>("Âu Mĩ", data);
      },
    );
  }

  Future<WeekChartModel> getKpopWeekChart() async {
    String api = '/kpop_week_chart';
    final int lazyTime = 24 * 60 * 60; // 1 ngày
    return _getOrFetch(
      api,
      lazyTime: lazyTime,
      fetchFunc: zingMp3.fetchKpopWeekChart,
      outputFixer: (data) {
        return WeekChartModel.fromJson<ZingMp3Api>("Hàn Quốc", data);
      },
    );
  }

  /* ----------------------
  |    STORAGE & CACHE    |
  ---------------------- */

  Future<Uri> getSongUri(String songId) async {
    final fileName = '$songId.mp3';
    final dir = storage.downloadDir;
    final filePath = '${dir.path}/$fileName';
    final file = File(filePath);

    if (await file.exists()) return Uri.file(filePath);

    final api = '/song_url?id=$songId';
    return storage.getCached<String>(api).fold<Future<Uri>>(
      (url) async => Uri.parse(url),
      (_) async {
        String? url = await FirebaseApi.getSongUrl(songId);
        if (url == null) {
          url = await zingMp3.fetchSongUrl(songId);
          unawaited(FirebaseApi.uploadSongFromUrl(url, songId));
        }
        unawaited(storage.updateCached(api, url));
        return Uri.parse(url);
      },
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

  Future<Map<String, dynamic>> getHomeJson() async {
    // TODO: bro, who on earth would name api /home2
    final String api = '/home2';
    final int lazyTime = 6 * 60 * 60; // 6 hours

    return await _getOrFetch<Map<String, dynamic>, Map<String, dynamic>>(
      api,
      lazyTime: lazyTime,
      fetchFunc: zingMp3.fetchHome,
    );
  }
}

List<Map<String, dynamic>> _getSongsForHomeOutputFixer(
  List<Map<String, dynamic>> data,
) {
  for (var songList in data) {
    final items = songList['items'];
    var songIds = List<String>.from(items.map((song) => song['encodeId']));

    songIds = getIt<ApiKit>().filterNonBlacklistedSongs(songIds).toList();
    songList['items'] =
        List.castFrom<dynamic, Map<String, dynamic>>(items)
            .where((song) => songIds.contains(song['encodeId']))
            .map((song) => SongModel.fromJson<ZingMp3Api>(song))
            .toList();
  }
  return data;
}
