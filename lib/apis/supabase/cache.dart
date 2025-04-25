import 'dart:developer';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:memecloud/apis/supabase/songs.dart';
import 'package:memecloud/apis/zingmp3.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/models/song_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseCacheApi {
  final SupabaseClient _client;
  SupabaseCacheApi(this._client);

  Future<Either<String, Map?>> _getCachedValueFor(
    String api, [
    int? lazyTime,
  ]) async {
    try {
      final response =
          await _client
              .from('api_cache')
              .select('value, created_at')
              .eq('api', api)
              .maybeSingle();
      if (response == null) return Right(null);

      final createdAt = DateTime.parse(response['created_at']);
      final now = DateTime.now();

      if (lazyTime != null && now.difference(createdAt).inSeconds > lazyTime) {
        return Right(null);
      } else {
        return Right(response['value'] as Map?);
      }
    } catch (e, stackTrace) {
      log(
        'Failed to get cached value for $api!',
        stackTrace: stackTrace,
        level: 1000,
      );
      return Left(e.toString());
    }
  }

  Future<Either<String, String?>> getSongPath(String songId) async {
    final dir = await getTemporaryDirectory();
    final fileName = '$songId.mp3';
    final filePath = '${dir.path}/$fileName';
    final file = File(filePath);

    if (await file.exists()) return Right(filePath);

    return (await getIt<SupabaseSongsApi>().isNonVipSong(
      songId,
    )).fold((l) => Left(l), (r) async {
      if (!r) return Right(null);

      try {
        var bytes = await _client.storage.from('songs').download(fileName);
        await file.writeAsBytes(bytes);
        return Right(filePath);
      } on StorageException catch (_) {
        var resp = await getIt<ZingMp3Api>().fetchSongUrl(songId);
        return resp.fold((l) => Left(l), (r) async {
          if (r == null) return Right(null);
          try {
            await getIt<Dio>().download(r, filePath);
          } catch (e, stackTrace) {
            log('Download failed! url=$r', stackTrace: stackTrace, level: 1000);
            return Left(e.toString());
          }

          var bytes = await File(filePath).readAsBytes();
          try {
            await _client.storage.from('songs').uploadBinary(fileName, bytes);
          } catch (e, stackTrace) {
            log(
              'Failed to upload song file to supabase: $e',
              stackTrace: stackTrace,
              level: 1000,
            );
          }
          return Right(filePath);
        });
      } catch (e, stackTrace) {
        log('Failed to download: $e', stackTrace: stackTrace, level: 1000);
        return Left(e.toString());
      }
    });
  }

  Future<Either<String, List>> getSongsForHomeOutputFixer(List data) async {
    try {
      for (var songList in data) {
        final items = songList['items'] as List;
        final songIds = items.map((song) => song['encodeId']).toList();

        final resp = await getIt<SupabaseSongsApi>().filterNonVipSongs(songIds);
        songList['items'] = resp.fold(
          (l) => throw l,
          (r) {
            return items
                  .where((song) => r.contains(song['encodeId']))
                  .map((song) => SongModel.fromJson<ZingMp3Api>(song))
                  .toList();
          }
        );
      }

      return Right(data);
    } catch (e, stackTrace) {
      log("Failed to get songs for home: $e", stackTrace: stackTrace, level: 1000);
      return Left(e.toString());
    }
  }

  Future<Either<String, List>> getSongsForHome() async {
    final String api = '/home';
    final int lazyTime = 1 * 60 * 60; // 1 hour

    final cached = await _getCachedValueFor(api, lazyTime);
    return cached.fold((l) => Left(l), (r) async {
      if (r != null) {
        return await getSongsForHomeOutputFixer(r['items']);
      }

      var resp = await getIt<ZingMp3Api>().home();
      return resp.fold((l) => Left(l), (r) async {
        await _client.from('api_cache').upsert({
          'api': api,
          'value': r,
          'created_at': DateTime.now().toIso8601String(),
        });
        return await getSongsForHomeOutputFixer(r['items']!);
      });
    });
  }
}
