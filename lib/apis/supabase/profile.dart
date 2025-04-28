import 'dart:developer';
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:memecloud/models/user_model.dart';
import 'package:mime/mime.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseProfileApi {
  final SupabaseClient _client;
  SupabaseProfileApi(this._client);

  final String _bucketName = 'images';
  final String _avatarFolder = 'avatar';

  Future<Either<String, UserModel?>> getProfile([String? userId]) async {
    try {
      userId ??= _client.auth.currentUser!.id;

      final userJson =
          await _client.from('users').select().eq('id', userId).single();
      debugPrint('User data retrieved: $userJson');

      final userModel = UserModel.fromJson(userJson);
      return Right(userModel);
    } catch (e, stackTrace) {
      log(
        'Error getting current user: $e',
        stackTrace: stackTrace,
        level: 1000,
      );
      return Left('Error: $e');
    }
  }

  Future<Either> changeName(String fullName) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return Left('User has not logged in');

      // Thay 'full_name' bằng tên cột chính xác trong database của bạn
      // Ví dụ: nếu tên cột là 'name'
      await _client
          .from('users')
          .update({
            'display_name': fullName,
          }) // Thay 'full_name' thành tên cột đúng
          .eq('id', userId);

      return Right(null);
    } catch (e) {
      return Left('Error $e');
    }
  }

  Future<Either> changePassword(String newPassword) async {
    // TODO: implement changePassword
    throw UnimplementedError();
  }

  Future<String?> setAvatar(File file) async {
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

    final publicUrl = _client.storage.from(_bucketName).getPublicUrl(filePath);

    await _client
        .from('users')
        .update({'avatar_url': publicUrl})
        .eq('id', userId);

    return publicUrl;
  }

  Future<void> unsetAvatar() async {
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
  }
}

String? _extensionFromMime(String? mimeType) {
  if (mimeType == null) return null;

  return extensionFromMime(mimeType);
}
