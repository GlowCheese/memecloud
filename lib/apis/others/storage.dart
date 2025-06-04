import 'dart:io';
import 'dart:convert';
import 'package:hive_flutter/adapters.dart';
import 'package:memecloud/apis/zingmp3/endpoints.dart';
import 'package:memecloud/models/playlist_model.dart';
import 'package:memecloud/utils/cookie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:memecloud/models/song_model.dart';
import 'package:memecloud/apis/supabase/main.dart';

class HiveBoxes {
  static Future<HiveBoxes> initialize() async {
    await Future.wait([
      Hive.openBox<Map>('apiCache'),
      Hive.openBox<String>('recentSearches'),
      Hive.openBox<String>('likedSongs'),
      Hive.openBox<String>('blacklistedSongs'),
      Hive.openBox<String>('followedPlaylists'),
      Hive.openBox<String>('downloadedSongs'),
      Hive.openBox<bool>('downloadedPlaylists'),
      Hive.openBox<String>('recentlyPlayedSongs'),
      Hive.openBox<String>('recentlyPlayedPlaylists'),
      Hive.openBox<String>('appConfig'),
    ]);
    return HiveBoxes();
  }

  Box<Map> get apiCache => Hive.box('apiCache');
  Box<String> get recentSearches => Hive.box('recentSearches');
  Box<String> get likedSongs => Hive.box('likedSongs');
  Box<String> get blacklistedSongs => Hive.box('blacklistedSongs');
  Box<String> get followedPlaylists => Hive.box('followedPlaylists');
  Box<String> get downloadedSongs => Hive.box('downloadedSongs');
  Box<bool> get downloadedPlaylists => Hive.box('downloadedPlaylists');
  Box<String> get recentlyPlayedSongs => Hive.box('recentlyPlayedSongs');
  Box<String> get recentlyPlayedPlaylists =>
      Hive.box('recentlyPlayedPlaylists');
  Box<String> get appConfig => Hive.box('appConfig');
}

class CachedDataWithFallback<T> {
  final T? data;
  final T? fallback;
  CachedDataWithFallback({this.data, this.fallback});

  R fold<R>(R Function(T data) onData, R Function(T? fallback) onFallback) {
    if (data != null) {
      return onData(data as T);
    } else {
      return onFallback(fallback);
    }
  }
}

class PersistentStorage {
  final Directory tempDir;
  final Directory cacheDir;
  final Directory userDir;
  final Directory supportDir;
  final Directory downloadDir;
  final HiveBoxes hiveBoxes;

  PersistentStorage._({
    required this.tempDir,
    required this.cacheDir,
    required this.userDir,
    required this.supportDir,
    required this.downloadDir,
    required this.hiveBoxes,
  });

  static Future<PersistentStorage> initialize() async {
    await Hive.initFlutter();

    return PersistentStorage._(
      tempDir: await getTemporaryDirectory(),
      cacheDir: await getApplicationCacheDirectory(),
      userDir: await getApplicationDocumentsDirectory(),
      supportDir: await getApplicationSupportDirectory(),
      downloadDir: (await getDownloadsDirectory())!,
      hiveBoxes: await HiveBoxes.initialize(),
    );
  }

  /* -------------------
  |    STORAGE CACHE   |
  ------------------- */

  CachedDataWithFallback<T> getCached<T>(String api, {int? lazyTime}) {
    final resp = hiveBoxes.apiCache.get(api);
    if (resp == null) return CachedDataWithFallback<T>();

    final createdAt = DateTime.fromMillisecondsSinceEpoch(resp['created_at']);
    final now = DateTime.now();

    if (lazyTime != null && now.difference(createdAt).inSeconds > lazyTime) {
      return CachedDataWithFallback<T>(fallback: jsonDecode(resp['data']));
    } else {
      return CachedDataWithFallback<T>(data: jsonDecode(resp['data']));
    }
  }

  Future<void> updateCached(String api, Object data) async {
    await hiveBoxes.apiCache.put(api, {
      'data': jsonEncode(data),
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  // TODO: should leverge this function more
  SongModel? getCachedSong(String songId) {
    String api = '/infosong?id=$songId';
    return getCached<Map<String, dynamic>>(
      api,
    ).fold((data) => SongModel.fromJson<SupabaseApi>(data), (fallback) => null);
  }

  PlaylistModel? getCachedPlaylist(String playlistId) {
    String api = '/infoplaylist?id=$playlistId';
    return getCached<Map<String, dynamic>>(api).fold((data) {
      return PlaylistModel.fromJson<ZingMp3Api>(data['data']);
    }, (fallback) => null);
  }

  /* --------------------
  |    ZingMp3 Cookie   |
  -------------------- */

  T? getZingCookie<T>() {
    final box = hiveBoxes.appConfig;
    final cookieStr = box.get('zing_cookie');
    if (cookieStr == null) return null;
    return convertCookieToType<String, T>(cookieStr);
  }

  Future<void> setCookie(String cookieStr) async {
    final box = hiveBoxes.appConfig;
    return await box.put('zing_cookie', cookieStr);
  }

  Future<String> updateCookie(List<String> cookies) async {
    var oldCookies = getZingCookie<Map<String, String>>() ?? {};
    for (var cookie in cookies) {
      final kv = cookieGetFirstKv(cookie);
      if (kv != null) oldCookies[kv[0]] = kv[1];
    }

    final cookieStr = convertCookieToString(oldCookies);

    final box = hiveBoxes.appConfig;
    await box.put('zing_cookie', cookieStr);
    return cookieStr;
  }

  /* ---------------------
  |    RECENTLY PLAYED   |
  |    SONGS/PLAYLISTS   |
  --------------------- */

  Future<void> saveRecentlyPlayedSong(SongModel song, {int lim = 20}) async {
    final box = hiveBoxes.recentlyPlayedSongs;

    List<String> current = box.values.toList();
    current.removeWhere((e) => jsonDecode(e)['id'] == song.id);

    current.insert(0, jsonEncode(song.toJson()));
    if (current.length > lim) current = current.sublist(0, lim);

    await Future.wait([
      for (int i = 0; i < current.length; i++) box.put(i, current[i]),
    ]);
  }

  Iterable<SongModel> getRecentlyPlayedSongs() {
    return hiveBoxes.recentlyPlayedSongs.values.map(
      (e) => SongModel.fromJson<SupabaseApi>(jsonDecode(e)),
    );
  }

  Future<void> saveRecentlyPlayedPlaylist(
    PlaylistModel playlist, {
    int lim = 20,
  }) async {
    final box = hiveBoxes.recentlyPlayedPlaylists;

    List<String> current = box.values.toList();
    current.removeWhere((e) => jsonDecode(e)['id'] == playlist.id);

    current.insert(0, jsonEncode(playlist.toJson()));
    if (current.length > lim) current = current.sublist(0, lim);

    await Future.wait([
      for (int i = 0; i < current.length; i++) box.put(i, current[i]),
    ]);
  }

  Iterable<PlaylistModel> getRecentlyPlayedPlaylists() {
    return hiveBoxes.recentlyPlayedPlaylists.values.map(
      (e) => PlaylistModel.fromJson<SupabaseApi>(jsonDecode(e)),
    );
  }

  /* ---------------------
  |    RECENT SEARCHES   |
  --------------------- */

  void saveSearch(String query, {int lim = 8, bool negate = false}) {
    final box = hiveBoxes.recentSearches;
    List<String> current = box.values.toList();

    current.remove(query);
    if (negate == false) {
      current.insert(0, query);
    }

    if (current.length > lim) {
      current = current.sublist(0, lim);
    }

    for (int i = 0; i < current.length; i++) {
      box.put(i, current[i]);
    }
  }

  Iterable<String> getRecentSearches() {
    return hiveBoxes.recentSearches.values;
  }

  /* -----------------------
  |    LIKED SONGS CACHE   |
  ----------------------- */

  List<SongModel> getLikedSongs() {
    final box = hiveBoxes.likedSongs;
    return SongModel.fromListJson<SupabaseApi>(
      box.values.map((e) => jsonDecode(e)).toList(),
    );
  }

  bool isSongLiked(String songId) {
    return hiveBoxes.likedSongs.containsKey(songId);
  }

  Future setSongIsLiked(SongModel song, bool isLiked) {
    final box = hiveBoxes.likedSongs;
    if (isLiked) {
      return box.put(song.id, jsonEncode(song.toJson()));
    }
    return box.delete(song.id);
  }

  Future<void> preloadUserLikedSongs(List<SongModel> songs) async {
    final box = hiveBoxes.likedSongs;
    await box.clear();
    await box.putAll({
      for (var song in songs) song.id: jsonEncode(song.toJson()),
    });
  }

  /* -----------------------------
  |    FOLLOWED PLAYLIST CACHE   |
  ----------------------------- */

  List<PlaylistModel> getFollowedPlaylists() {
    final box = hiveBoxes.followedPlaylists;
    return PlaylistModel.fromListJson<SupabaseApi>(
      box.values.map((e) => jsonDecode(e)).toList(),
    );
  }

  bool isPlaylistFollowed(String playlistId) {
    return hiveBoxes.followedPlaylists.containsKey(playlistId);
  }

  Future setPlaylistIsFollowed(PlaylistModel playlist, bool isFollowed) {
    final box = hiveBoxes.followedPlaylists;
    if (isFollowed) {
      return box.put(playlist.id, jsonEncode(playlist.toJson()));
    }
    return box.delete(playlist.id);
  }

  Future<void> preloadUserFollowedPlaylists(
    List<PlaylistModel> playlists,
  ) async {
    final box = hiveBoxes.followedPlaylists;
    await box.clear();
    await box.putAll({
      for (var playlist in playlists)
        playlist.id: jsonEncode(playlist.toJson()),
    });
  }

  /* -----------------------------
  |    BLACKLISTED SONGS CACHE   |
  ----------------------------- */

  List<SongModel> getBlacklistedSongs() {
    final box = hiveBoxes.blacklistedSongs;
    return SongModel.fromListJson<SupabaseApi>(
      box.values.map((e) => jsonDecode(e)).toList(),
      includeBlacklisted: true,
    );
  }

  bool isSongBlacklisted(String songId) {
    return hiveBoxes.blacklistedSongs.containsKey(songId);
  }

  Future<void> setIsBlacklisted(SongModel song, bool isBlacklisted) {
    final box = hiveBoxes.blacklistedSongs;
    if (isBlacklisted) {
      return box.put(song.id, jsonEncode(song.toJson()));
    }
    return box.delete(song.id);
  }

  Iterable<String> filterNonBlacklistedSongs(Iterable<String> songIds) {
    return songIds.where((songId) => !isSongBlacklisted(songId));
  }

  Future<void> preloadUserBlacklistedSongs(List<SongModel> songs) async {
    final box = hiveBoxes.blacklistedSongs;
    await box.clear();
    await box.putAll({
      for (var song in songs) song.id: jsonEncode(song.toJson()),
    });
  }

  /* --------------------
  |    SONG DOWNLOADS   |
  -------------------- */

  bool isSongDownloaded(String songId) {
    return hiveBoxes.downloadedSongs.containsKey(songId);
  }

  List<SongModel> getDownloadedSongs() {
    return [
      for (var json in hiveBoxes.downloadedSongs.values)
        SongModel.fromJson<SupabaseApi>(jsonDecode(json)),
    ];
  }

  Future<void> markSongAsDownloaded(SongModel song) {
    return hiveBoxes.downloadedSongs.put(song.id, jsonEncode(song.toJson()));
  }

  Future<void> markSongAsNotDownloaded(String songId) {
    return hiveBoxes.downloadedSongs.delete(songId);
  }

  bool isPlaylistDownloaded(String playlistId) {
    return hiveBoxes.downloadedPlaylists.containsKey(playlistId);
  }

  List<PlaylistModel> getDownloadedPlaylists() {
    return [
      for (String playlistId in hiveBoxes.downloadedPlaylists.keys)
        getCachedPlaylist(playlistId)!,
    ];
  }

  Future<void> markPlaylistAsDownloaded(String playlistId) async {
    await hiveBoxes.downloadedPlaylists.put(playlistId, true);
  }

  Future<void> markPlaylistAsNotDownloaded(String playlistId) async {
    await hiveBoxes.downloadedPlaylists.delete(playlistId);
  }
}
