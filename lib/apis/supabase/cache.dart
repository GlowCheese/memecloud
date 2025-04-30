import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/apis/storage.dart';
import 'package:memecloud/apis/connectivity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseCacheApi {
  final SupabaseClient _client;
  final _connectivity = getIt<ConnectivityStatus>();
  SupabaseCacheApi(this._client);

  Future<CachedDataWithFallback<Map>> getCached(
    String api, {
    int? lazyTime,
  }) async {
    try {
      _connectivity.ensure();
      final response =
          await _client
              .from('api_cache')
              .select('data, created_at')
              .eq('api', api)
              .maybeSingle();
      if (response == null) return CachedDataWithFallback<Map>();

      final createdAt = DateTime.parse(response['created_at']);
      final now = DateTime.now();

      if (lazyTime == null || now.difference(createdAt).inSeconds < lazyTime) {
        return CachedDataWithFallback<Map>(data: response['data'] as Map);
      } else {
        return CachedDataWithFallback<Map>(fallback: response['data'] as Map);
      }
    } catch (e, stackTrace) {
      _connectivity.reportCrash(e, StackTrace.current);
      log(
        'Failed to get cached data for $api!',
        stackTrace: stackTrace,
        level: 1000,
      );
      rethrow;
    }
  }

  /// return `null` if cannot found song file on remote,
  /// otherwise return the bytes for the song from remote.
  Future<Uint8List?> getSongFile(String songId) async {
    final fileName = '$songId.mp3';
    try {
      _connectivity.ensure();
      return await _client.storage.from('songs').download(fileName);
    } on StorageException {
      return null;
    } catch (e, stackTrace) {
      _connectivity.reportCrash(e, StackTrace.current);
      log(
        'Supabase failed to get song file: $e',
        stackTrace: stackTrace,
        level: 1000,
      );
      rethrow;
    }
  }

  Future<String> uploadSongFile(String fileName, Uint8List bytes) {
    try {
      _connectivity.ensure();
      return _client.storage.from('songs').uploadBinary(fileName, bytes);
    } catch (e, stackTrace) {
      _connectivity.reportCrash(e, StackTrace.current);
      log(
        'Failed to upload song to Supabase storage: $e',
        stackTrace: stackTrace,
        level: 900,
      );
      rethrow;
    }
  }
}
