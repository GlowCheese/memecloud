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

  Future<Either<String, Map?>> getCached(String api, {int? lazyTime}) async {
    try {
      final response =
          await _client
              .from('api_cache')
              .select('data, created_at')
              .eq('api', api)
              .maybeSingle();
      if (response == null) return Right(null);

      final createdAt = DateTime.parse(response['created_at']);
      final now = DateTime.now();

      if (lazyTime != null && now.difference(createdAt).inSeconds > lazyTime) {
        return Right(null);
      } else {
        return Right(response['data'] as Map);
      }
    } catch (e, stackTrace) {
      log(
        'Failed to get cached data for $api!',
        stackTrace: stackTrace,
        level: 1000,
      );
      return Left(e.toString());
    }
  }

  // TODO: should separate to: getSongFile, (downloadSong) and updateSongFile
  Future<Either<String, Uint8List?>> getSongFile(String songId) async {
    return (await getIt<ApiKit>().isNonVipSong(songId)).fold((l) => Left(l), (
      r,
    ) async {
      if (!r) return Right(null);

      final tmpDir = getIt<PersistentStorage>().tempDir;
      final fileName = '$songId.mp3';
      final filePath = '${tmpDir.path}/$fileName';
      final file = File(filePath);

      try {
        var bytes = await _client.storage.from('songs').download(fileName);
        await file.writeAsBytes(bytes);
        return Right(bytes);
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
          return Right(bytes);
        });
      } catch (e, stackTrace) {
        log('Failed to download: $e', stackTrace: stackTrace, level: 1000);
        return Left(e.toString());
      }
    });
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
}
