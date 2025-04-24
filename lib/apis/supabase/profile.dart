import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:memecloud/models/user_model.dart';
import 'package:mime/mime.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseProfileApi {
  final SupabaseClient _client;
  SupabaseProfileApi(this._client);

  final String _bucketName = 'images';
  final String _avatarFolder = 'avatar';

  Future<Either> getCurrentUser() async {
    try {
      User? user = _client.auth.currentUser;
      if (user == null) return Left('User has not logged in');
      String id = user.id;
      final userJson =
          await _client.from('users').select().eq('id', id).single();
      return Right(UserModel.fromJson(userJson));
    } catch (e) {
      return Left('Error $e');
    }
  }

  Future<Either> changePassword(String newPassword) {
    // TODO: implement changePassword
    throw UnimplementedError();
  }

  Future<String?> uploadAvatar(File file) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;

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

  Future<void> deleteAvatar(String userId) async {
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

    Future<Either> changeName(String newName) {
    // TODO: implement changeName
    throw UnimplementedError();
  }
}

String? _extensionFromMime(String? mimeType) {
  if (mimeType == null) return null;

  return extensionFromMime(mimeType);
}
