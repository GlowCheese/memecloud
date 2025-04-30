import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';

class HiveBoxes {
  static Future<HiveBoxes> initialize() async {
    await Future.wait([
      Hive.openBox<bool>('savedSongsInfo'),
      Hive.openBox<bool>('vipSongs'),
      Hive.openBox<Map>('apiCache'),
      Hive.openBox<List<int>>('paletteColors'),
    ]);
    return HiveBoxes();
  }

  Box<bool> get savedSongsInfo => Hive.box('savedSongsInfo');
  Box<bool> get vipSongs => Hive.box('vipSongs');
  Box<Map> get apiCache => Hive.box('apiCache');
  Box<List<int>> get paletteColors => Hive.box('paletteColors');
}

class CachedDataWithFallback<T> {
  final T? data;
  final T? fallback;
  CachedDataWithFallback({this.data, this.fallback});

  R fold<R>(R Function(T data) onData, R Function(T? fallback) onFallback) {
    if (data != null) {
      return onData(data as T);
    } else  {
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

  Future<void> markSongInfoAsSaved(String songId) async {
    await hiveBoxes.savedSongsInfo.put(songId, true);
  }

  bool isSongInfoSaved(String songId) {
    return hiveBoxes.savedSongsInfo.containsKey(songId);
  }

  Future<void> markSongAsVip(String songId) async {
    await hiveBoxes.vipSongs.put(songId, true);
  }

  Future<void> markSongAsNonVip(String songId) async {
    await hiveBoxes.vipSongs.put(songId, false);
  }

  bool? isNonVipSong(String songId) {
    bool? x = hiveBoxes.vipSongs.get(songId);
    return x == null ? null : !x;
  }

  List filterNonVipSongs(List songIds) {
    return songIds.where((songId) => isNonVipSong(songId) == true).toList();
  }

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

  List<Color>? getPaletteColors(String url) {
    final value = hiveBoxes.paletteColors.get(url);
    if (value == null) return null;
    return value.map((e) => Color(e)).toList();
  }

  Future<void> setPaletteColors(String url, List<Color> colors) async {
    await hiveBoxes.paletteColors.put(url, colors.map((e) => e.toARGB32()).toList());
  }
}
