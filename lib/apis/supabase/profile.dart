import 'dart:io';
import 'dart:developer';
import 'package:mime/mime.dart';
import 'package:dartz/dartz.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/apis/others/connectivity.dart';
import 'package:memecloud/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseProfileApi {
  final SupabaseClient _client;
  SupabaseProfileApi(this._client);
  final _connectivity = getIt<ConnectivityStatus>();

  final String _bucketName = 'images';
  final String _avatarFolder = 'avatar';

  Future<UserModel?> getProfile([String? userId]) async {
    try {
      _connectivity.ensure();
      userId ??= _client.auth.currentUser!.id;
      final userJson =
          await _client.from('users').select().eq('id', userId).maybeSingle();
      if (userJson == null) return null;
      return UserModel.fromJson(userJson);
    } catch (e, stackTrace) {
      _connectivity.reportCrash(e, StackTrace.current);
      log(
        'Error getting current user: $e',
        stackTrace: stackTrace,
        level: 1000,
      );
      rethrow;
    }
  }

  Future<void> changeName(String fullName) async {
    try {
      _connectivity.ensure();
      final userId = _client.auth.currentUser!.id;
      await _client
          .from('users')
          .update({'display_name': fullName})
          .eq('id', userId);
    } catch (e, stackTrace) {
      _connectivity.reportCrash(e, StackTrace.current);
      log('Failed to change name: $e', stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<Either> changePassword(String newPassword) async {
    // TODO: implement changePassword
    throw UnimplementedError();
  }

  Future<String?> setAvatar(File file) async {
    try {
      _connectivity.ensure();
      final userId = _client.auth.currentUser!.id;

      final mimeType = lookupMimeType(file.path);
      final fileExt = _extensionFromMime(mimeType) ?? file.path.split('.').last;
      final filePath = '$_avatarFolder/$userId.$fileExt';

      await _client.storage
          .from(_bucketName)
          .upload(
            filePath,
            file,
            fileOptions: FileOptions(contentType: mimeType, upsert: true),
          );

      final publicUrl = _client.storage
          .from(_bucketName)
          .getPublicUrl(filePath);

      await _client
          .from('users')
          .update({'avatar_url': publicUrl})
          .eq('id', userId);

      return publicUrl;
    } catch (e, stackTrace) {
      _connectivity.reportCrash(e, StackTrace.current);
      log('Failed to set avatar: $e', stackTrace: stackTrace, level: 1000);
      rethrow;
    }
  }

  Future<void> unsetAvatar() async {
    try {
      _connectivity.ensure();
      final userId = _client.auth.currentUser!.id;

      final list = await _client.storage
          .from(_bucketName)
          .list(path: _avatarFolder);

      FileObject? file;
      try {
        file = list.firstWhere((f) => f.name.startsWith(userId));
      } catch (_) {
        file = null;
      }

      if (file != null) {
        await _client.storage.from(_bucketName).remove([
          '$_avatarFolder/${file.name}',
        ]);
      }

      await _client
          .from('profiles')
          .update({'avatar_url': null})
          .eq('id', userId);
    } catch (e, stackTrace) {
      _connectivity.reportCrash(e, StackTrace.current);
      log('Failed to unset avatar: $e', stackTrace: stackTrace, level: 1000);
      rethrow;
    }
  }
}

String? _extensionFromMime(String? mimeType) {
  if (mimeType == null) return null;

  return extensionFromMime(mimeType);
}
