import 'dart:io';
import 'dart:convert';
import 'package:hive_flutter/adapters.dart';
import 'package:memecloud/apis/supabase/main.dart';
import 'package:memecloud/models/song_model.dart';
import 'package:path_provider/path_provider.dart';

class HiveBoxes {
  static Future<HiveBoxes> initialize() async {
    await Future.wait([
      Hive.openBox<bool>('savedInfo'),
      Hive.openBox<bool>('vipSongs'),
      Hive.openBox<Map>('apiCache'),
      Hive.openBox<String>('recentSearches'),
      Hive.openBox<String>('likedSongs'),
      Hive.openBox<String>('blacklistedSongs'),
      Hive.openBox<bool>('downloadedSongs'),
      Hive.openBox<int>('songDownloadDeps')
    ]);
    return HiveBoxes();
  }

  Box<bool> get savedInfo => Hive.box('savedInfo');
  Box<bool> get vipSongs => Hive.box('vipSongs');
  Box<Map> get apiCache => Hive.box('apiCache');
  Box<String> get recentSearches => Hive.box('recentSearches');
  Box<String> get likedSongs => Hive.box('likedSongs');
  Box<String> get blacklistedSongs => Hive.box('blacklistedSongs');
  Box<bool> get downloadedSongs => Hive.box('downloadedSongs');
  Box<int> get songDownloadDeps => Hive.box('songDownloadDeps');
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
  final HiveBoxes hiveBoxes;

  PersistentStorage._({
    required this.tempDir,
    required this.cacheDir,
    required this.userDir,
    required this.supportDir,
    required this.hiveBoxes,
  });

  static Future<PersistentStorage> initialize() async {
    await Hive.initFlutter();

    return PersistentStorage._(
      tempDir: await getTemporaryDirectory(),
      cacheDir: await getApplicationCacheDirectory(),
      userDir: await getApplicationDocumentsDirectory(),
      supportDir: await getApplicationSupportDirectory(),
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

  /* ----------------
  |    SAVED INFO   |
  ---------------- */

  Future<void> markInfoAsSaved(String id, String category) {
    return hiveBoxes.savedInfo.put('$category=$id', true);
  }

  bool isInfoSaved(String id, String category) {
    return hiveBoxes.savedInfo.containsKey('$category=$id');
  }

  /* ---------------------
  |    RECENT SEARCHES   |
  --------------------- */

  void saveSearch(String query, {int lim = 10, bool negate = false}) {
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

  Future setIsLiked(SongModel song, bool isLiked) {
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
  |    BLACKLISTED SONGS CACHE   |
  ----------------------------- */

  List<SongModel> getBlacklistedSongs() {
    final box = hiveBoxes.blacklistedSongs;
    return SongModel.fromListJson<SupabaseApi>(
      box.values.map((e) => jsonDecode(e)).toList(),
    );
  }

  bool isSongBlacklisted(String songId) {
    return hiveBoxes.blacklistedSongs.containsKey(songId);
  }

  Future setIsBlacklisted(SongModel song, bool isBlacklisted) {
    final box = hiveBoxes.blacklistedSongs;
    if (isBlacklisted) {
      return box.put(song.id, jsonEncode(song.toJson()));
    }
    return box.delete(song.id);
  }

  Future<void> preloadUserBlacklistedSongs(List<SongModel> songs) async {
    final box = hiveBoxes.blacklistedSongs;
    await box.clear();
    await box.putAll({
      for (var song in songs) song.id: jsonEncode(song.toJson()),
    });
  }

  /* ----------------------
  |    VIP SONGs FILTER   |
  ---------------------- */

  Future<void> markSongAsVip(String songId) async {
    await hiveBoxes.vipSongs.put(songId, true);
  }

  bool isNonVipSong(String songId) {
    return !hiveBoxes.vipSongs.containsKey(songId);
  }

  Iterable<String> filterNonVipSongs(Iterable<String> songIds) {
    return songIds.where((songId) => isNonVipSong(songId));
  }

  Future<void> preloadVipSongs(List<String> vipSongIds) {
    return hiveBoxes.vipSongs.putAll({
      for (var songId in vipSongIds) songId: true,
    });
  }

  /* --------------------
  |    SONG DOWNLOADS   |
  -------------------- */

  int? _songDownloadDeps(String songId) {
    return hiveBoxes.songDownloadDeps.get(songId);
  }

  bool isSongDownloaded(String songId) {
    return hiveBoxes.downloadedSongs.containsKey(songId);
  }

  Future<void> markSongAsDownloaded(String songId) {
    return Future.wait([
      hiveBoxes.downloadedSongs.put(songId, true),
      hiveBoxes.songDownloadDeps.put(songId, (_songDownloadDeps(songId) ?? 0) + 1)
    ]);
  }

  Future<void> undownloadSong(String songId) {
    return Future.wait([
      hiveBoxes.downloadedSongs.delete(songId),
      hiveBoxes.songDownloadDeps.put(songId, (_songDownloadDeps(songId) ?? 0) - 1)
    ]);
  }
}
