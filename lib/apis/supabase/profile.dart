import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:memecloud/models/user_model.dart';
import 'package:mime/mime.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logging/logging.dart';

class SupabaseProfileApi {
  final SupabaseClient _client;
  SupabaseProfileApi(this._client);

  final String _bucketName = 'images';
  final String _avatarFolder = 'avatar';
  final Logger _logger = Logger('SupabaseProfileApi');

  // Future<Either> getCurrentUser() async {
  //   try {
  //     User? user = _client.auth.currentUser;
  //     if (user == null) return Left('User has not logged in');
  //     String id = user.id;
  //     final userJson =
  //         await _client.from('users').select().eq('id', id).single();
  //     return Right(UserModel.fromJson(userJson));
  //   } catch (e) {
  //     return Left('Error $e');
  //   }
  // }

  Future<Either<String, UserModel?>> getCurrentUser() async {
    try {
      // Lấy user hiện tại từ Supabase auth
      User? user = _client.auth.currentUser;

      if (user == null) {
        _logger.warning('User has not logged in');
        return Left('User has not logged in');
      }

      String id = user.id;
      _logger.info('Getting user profile for id: $id');

      try {
        // Truy vấn thông tin user từ bảng 'users'
        final userJson =
            await _client
                .from('users')
                .select()
                .eq('id', id)
                .maybeSingle(); // Sử dụng maybeSingle thay vì single

        _logger.info('User data retrieved: $userJson');

        // Nếu không tìm thấy user
        if (userJson == null) {
          _logger.warning('User record not found in database');
          return Right(null);
        }

        // Parse JSON thành UserModel
        final userModel = UserModel.fromJson(userJson);
        return Right(userModel);
      } catch (supabaseError) {
        _logger.severe('Supabase query error: $supabaseError');
        return Left('Supabase query error: $supabaseError');
      }
    } catch (e, stackTrace) {
      _logger.severe('Error getting current user: $e', e, stackTrace);
      return Left('Error: $e');
    }
  }

  Future<Either> updateUserInfo(String fullName, String email) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return Left('User has not logged in');

      await _client
          .from('users')
          .update({'full_name': fullName, 'email': email})
          .eq('id', userId);

      return Right(null);
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
