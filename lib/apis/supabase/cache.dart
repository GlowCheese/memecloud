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

  Future<Uint8List?> getFile(String bucket, String fileName) async {
    try {
      _connectivity.ensure();
      return await _client.storage.from(bucket).download(fileName);
    } on StorageException {
      return null;
    } catch (e, stackTrace) {
      _connectivity.reportCrash(e, StackTrace.current);
      log(
        'Supabase failed to get file from bucket $bucket: $e',
        stackTrace: stackTrace,
        level: 1000,
      );
      rethrow;
    }
  }

  Future<String?> uploadFile(
    String bucket,
    String fileName,
    Uint8List bytes,
  ) async {
    try {
      _connectivity.ensure();
      return await _client.storage.from(bucket).uploadBinary(fileName, bytes);
    } on StorageException catch (e, stackTrace) {
      log(
        'Skip uploading $fileName to $bucket. Reason: $e',
        stackTrace: stackTrace,
        level: 1000,
      );
      return null;
    } catch (e, stackTrace) {
      _connectivity.reportCrash(e, StackTrace.current);
      log(
        'Failed to upload file to bucket $bucket: $e',
        stackTrace: stackTrace,
        level: 1000,
      );
      rethrow;
    }
  }
}
