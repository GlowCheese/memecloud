import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:memecloud/apis/storage.dart';
import 'package:memecloud/apis/zingmp3.dart';
import 'package:memecloud/core/getit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseCacheApi {
  final SupabaseClient _client;
  SupabaseCacheApi(this._client);

  Future<Either<String, CachedDataWithFallback>> getCached(String api, {int? lazyTime}) async {
    try {
      getIt<ApiKit>().ensureConnectivity();
      final response =
          await _client
              .from('api_cache')
              .select('data, created_at')
              .eq('api', api)
              .maybeSingle();
      if (response == null) return Right(CachedDataWithFallback());

      final createdAt = DateTime.parse(response['created_at']);
      final now = DateTime.now();

      if (lazyTime == null || now.difference(createdAt).inSeconds < lazyTime) {
        return Right(CachedDataWithFallback(data: response['data'] as Map));
      } else {
        return Right(CachedDataWithFallback(fallback: response['data'] as Map));
      }
    } catch (e, stackTrace) {
      if (!getIt<ApiKit>().reportConnectivityCrash(e)) {
        log(
          'Failed to get cached data for $api!',
          stackTrace: stackTrace,
          level: 1000,
        );
      }
      return Left(e.toString());
    }
  }

  Future<Either<String, Uint8List?>> getchSongFile(String songId) async {
    final tmpDir = getIt<PersistentStorage>().tempDir;
    final fileName = '$songId.mp3';
    final filePath = '${tmpDir.path}/$fileName';
    final file = File(filePath);

    try {
      getIt<ApiKit>().ensureConnectivity();
      var bytes = await _client.storage.from('songs').download(fileName);
      await file.writeAsBytes(bytes);
      return Right(bytes);
    } on StorageException catch (_) {
      return (await getIt<ZingMp3Api>().fetchSongUrl(songId)).fold(
        (l) => Left(l),
        (r) async {
          if (r == null) return Right(null);

          final tmpDir = getIt<PersistentStorage>().tempDir;
          final fileName = '$songId.mp3';
          final filePath = '${tmpDir.path}/$fileName';
          final file = File(filePath);

          try {
            await getIt<Dio>().download(r, filePath);
          } catch (e, stackTrace) {
            log('Download failed! url=$r', stackTrace: stackTrace, level: 1000);
            return Left(e.toString());
          }

          var bytes = await file.readAsBytes();
          unawaited(
            _client.storage
                .from('songs')
                .uploadBinary(fileName, bytes)
                .catchError((e, stackTrace) {
                  log(
                    'Failed to upload song to Supabase storage: $e',
                    stackTrace: stackTrace,
                    level: 900,
                  );
                  return "";
                }),
          );
          return Right(bytes);
        },
      );
    } catch (e, stackTrace) {
      if (!getIt<ApiKit>().reportConnectivityCrash(e)) {
        log('Failed to download: $e', stackTrace: stackTrace, level: 1000);
      }
      return Left(e.toString());
    } finally {
      unawaited(file.delete().catchError((_) => file));
    }
  }

  Future<Either<String, Map>> getSongsForHome() async {
    final String api = '/home';

    return (await getIt<ZingMp3Api>().fetchHome()).fold((l) => Left(l), (
      r,
    ) async {
      await _client.from('api_cache').upsert({'api': api, 'data': r});
      return Right(r);
    });
  }

  Future<Either<String, Map>> search(String keyword) async {
    final String api = '/search?keyword=$keyword';

    return (await getIt<ZingMp3Api>().search(keyword)).fold((l) => Left(l), (
      r,
    ) async {
      await _client.from('api_cache').upsert({'api': api, 'data': r});
      return Right(r);
    });
  }
}
