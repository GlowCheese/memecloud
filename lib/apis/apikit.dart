import 'dart:developer';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:memecloud/apis/storage.dart';
import 'package:memecloud/apis/supabase/main.dart';
import 'package:memecloud/apis/zingmp3.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/models/song_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ApiKit {
  final SupabaseApi supabase;
  final SupabaseClient client;
  final PersistentStorage storage;

  ApiKit._({
    required this.supabase,
    required this.client,
    required this.storage,
  });

  static Future<ApiKit> initialize({required PersistentStorage storage}) async {
    await initializeSupabase();
    final supabase = SupabaseApi();
    return ApiKit._(
      supabase: supabase,
      client: supabase.client,
      storage: storage,
    );
  }

  /* ------------------------------
  |    CONNECTIVITY VALIDATION    |
  ------------------------------ */

  String ignoreStatusCode = 'IGNORE_1302';
  DateTime _lastConnectivityCrash = DateTime.fromMillisecondsSinceEpoch(0);
  /// Stop a method from calling API for `15` seconds
  /// if connectivity is unstable.
  void ensureConnectivity() {
    if (DateTime.now().difference(_lastConnectivityCrash).inSeconds < 15) {
      throw AuthException('SocketException: Lost connection', statusCode: ignoreStatusCode);
    }
  }
  /// Use this when encountering an exception that potentially due
  /// to connectivity issue. Return `true` if we suspect `e`
  /// originates from a `SocketException`. Otherwise return `false`.
  bool reportConnectivityCrash(Object e) {
    if (e is! Exception) return false;

    if (e.toString().contains('SocketException')) {
      if (e is! AuthException || e.statusCode == ignoreStatusCode) {
        _lastConnectivityCrash = DateTime.now();
      }
      log('${e.runtimeType} detected: $e', level: 900);
      return true;
    }

    return false;
  }

  /* ---------------------
  |    AUTHENTICATION    |
  --------------------- */

  User? currentUser() => supabase.auth.currentUser();
  Session? currentSession() => supabase.auth.currentSession();
  Future<Either> signIn({
    required String email,
    required String password,
  }) async => await supabase.auth.signIn(email, password);
  Future<Either> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async => await supabase.auth.signUp(email, password, fullName);
  Future<void> signOut() async => await supabase.auth.signOut();

  /* -------------------
  |    PROFILE APIs    |
  ------------------- */

  Future<Either> getProfile({String? userId}) async =>
      await supabase.profile.getProfile(userId);
  Future<Either> changeName(String newName) async =>
      await supabase.profile.changeName(newName);
  Future<String?> setAvatar(File file) async =>
      await supabase.profile.setAvatar(file);
  Future<void> unsetAvatar() async => await supabase.profile.unsetAvatar();

  /* ----------------
  |    SONGS APIs   |
  ---------------- */

  Future<Either<String, Null>> saveSongInfo(SongModel song) async {
    if (storage.isSongInfoSaved(song.id)) {
      debugPrint("Song info of '${song.id}' already marked as saved!");
      return Right(null);
    }
    return (await supabase.songs.saveSongInfo(song)).fold((l) => Left(l), (
      Null r,
    ) async {
      return (await supabase.artists.saveSongArtists(
        song.id,
        song.artists,
      )).fold((l) => Left(l), (Null r) {
        storage.markSongInfoAsSaved(song.id);
        return Right(r);
      });
    });
  }

  Future<Either<String, bool>> getIsLiked(String songId) async =>
      await supabase.songs.getIsLiked(songId);
  Future<Either<String, Null>> setIsLiked(String songId, bool isLiked) async =>
      await supabase.songs.setIsLiked(songId, isLiked);
  Future<Either<String, List<SongModel>>> getLikedSongsList() async =>
      await supabase.songs.getLikedSongsList();
  Future<Either<String, bool>> isNonVipSong(String songId) async {
    bool? cached = storage.isNonVipSong(songId);
    if (cached != null) return Right(cached);
    return (await supabase.songs.isNonVipSong(songId)).fold((l) => Left(l), (
      r,
    ) {
      r ? storage.markSongAsNonVip(songId) : storage.markSongAsVip(songId);
      return Right(r);
    });
  }

  Future<void> markSongAsNonVip(String songId) async =>
      await storage.markSongAsNonVip(songId);
  Future<Either<String, Null>> markSongAsVip(String songId) async {
    storage.markSongAsVip(songId);
    return await supabase.songs.addSongToVip(songId);
  }

  Future<Either<String, List>> filterNonVipSongs(List songsIds) async =>
      (await supabase.songs.filterNonVipSongs(songsIds)).fold(
        (l) => Right(storage.filterNonVipSongs(songsIds)),
        (r) => Right(r),
      );

  /* ---------------------
  |    SUPABASE CACHE    |
  |     AND STORAGE      |
  --------------------- */

  Future<Either<String, String?>> getSongPath(String songId) async {
    final fileName = '$songId.mp3';
    late Directory dir;
    late String filePath;
    late File file;

    for (dir in [storage.userDir, storage.cacheDir]) {
      file = File(filePath = '${dir.path}/$fileName');
      if (await file.exists()) return Right(filePath);
    }

    return (await isNonVipSong(songId)).fold(
      (l) => Left(l),
      (r) async =>
          (!r)
              ? Right(null)
              : (await supabase.cache.getchSongFile(songId)).fold(
                (l) => Left(l),
                (r) async {
                  if (r == null) return Right(null);
                  await file.writeAsBytes(r);
                  return Right(filePath);
                },
              ),
    );
  }

  Future<Either<String, CachedDataWithFallback>> getCached(
    String api, {
    int? lazyTime,
  }) async {
    final localResp = storage.getCached(api, lazyTime: lazyTime);
    if (localResp.data != null) {
      debugPrint("Found local cache for $api!");
      return Right(localResp);
    }

    return (await supabase.cache.getCached(api, lazyTime: lazyTime)).fold(
      (l) => localResp.fallback != null ? Right(localResp) : Left(l),
      (r) {
        if (r.data != null) {
          storage.updateCached(api, r.data);
        }
        return Right(r);
      },
    );
  }

  Future<Either<String, List>> getSongsForHome() async {
    final String api = '/home';
    final int lazyTime = 45 * 60; // 45 minutes

    return (await getCached(api, lazyTime: lazyTime)).fold(
      (l) => Left(l),
      (r) => r.fold(
        (data) async => await _getSongsForHomeOutputFixer(data['items']),
        (fallback) async => (await supabase.cache.getSongsForHome()).fold(
          (l) async =>
              fallback != null
                  ? await _getSongsForHomeOutputFixer(fallback['items'])
                  : Left(l),
          (r) async {
            await storage.updateCached(api, r);
            return await _getSongsForHomeOutputFixer(r['items']);
          },
        ),
      ),
    );
  }
}

Future<Either<String, List>> _getSongsForHomeOutputFixer(List data) async {
  try {
    for (var songList in data) {
      final items = songList['items'] as List;
      final songIds = items.map((song) => song['encodeId']).toList();

      final resp = await getIt<ApiKit>().filterNonVipSongs(songIds);
      songList['items'] = resp.fold((l) => throw l, (r) {
        return items
            .where((song) => r.contains(song['encodeId']))
            .map((song) => SongModel.fromJson<ZingMp3Api>(song))
            .toList();
      });
    }

    return Right(data);
  } catch (e, stackTrace) {
    log(
      "Failure in getSongsForHomeOutputFixer: $e",
      stackTrace: stackTrace,
      level: 1000,
    );
    return Left(e.toString());
  }
}
