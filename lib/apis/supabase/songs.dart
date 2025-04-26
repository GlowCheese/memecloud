import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:memecloud/apis/supabase/main.dart';
import 'package:memecloud/models/song_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseSongsApi {
  final SupabaseClient _client;
  SupabaseSongsApi(this._client);

  Future<Either<String, Null>> saveSongInfo(SongModel song) async {
    final releaseDate = song.releaseDate.toUtc().toIso8601String();
    try {
      try {
        await _client.from('songs').insert({
          'id': song.id,
          'title': song.title,
          'artists_names': song.artistsNames,
          'thumbnail_url': song.thumbnailUrl,
          'release_date': releaseDate,
        });
        return Right(null);
      } on PostgrestException {
        return Right(null);
      }
    } catch (e, stackTrace) {
      log("Failed to save song info: $e", stackTrace: stackTrace, level: 1000);
      return Left(e.toString());
    }
  }

  Future<Either<String, bool>> getIsLiked(String songId) async {
    try {
      final userId = _client.auth.currentUser!.id;
      final response =
          await _client
              .from('liked_songs')
              .select('song_id')
              .eq('user_id', userId)
              .eq('song_id', songId)
              .maybeSingle();
      return Right(response != null);
    } catch (e, stackTrace) {
      log('Failed to getIsLiked: $e', stackTrace: stackTrace, level: 1000);
      return Left(e.toString());
    }
  }

  Future<Either<String, Null>> setIsLiked(String songId, bool isLiked) async {
    try {
      final userId = _client.auth.currentUser!.id;

      if (isLiked) {
        await _client
            .from('liked_songs')
            .upsert(
              {'user_id': userId, 'song_id': songId},
              onConflict: 'user_id,song_id',
              ignoreDuplicates: true,
            );
      } else {
        await _client.from('liked_songs').delete().match({
          'user_id': userId,
          'song_id': songId,
        });
      }
      return Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, List<SongModel>>> getLikedSongsList() async {
    try {
      final userId = _client.auth.currentUser!.id;

      final response = await _client
          .from('liked_songs')
          .select('''songs(
            *,
            song_artists(
              artist:artists (*)
            )
          )''')
          .eq('user_id', userId);

      final songsList =
          (response as List).map((item) {
            return SongModel.fromJson<SupabaseApi>(
              item['songs'],
              isLiked: true,
            );
          }).toList();

      return Right(songsList);
    } catch (e, stackTrace) {
      log("Failed to get liked songs: $e", stackTrace: stackTrace, level: 1000);
      return Left(e.toString());
    }
  }

  Future<Either<String, List>> filterNonVipSongs(List songsIds) async {
    try {
      final resp = await _client
          .from('vip_songs')
          .select('song_id')
          .inFilter('song_id', songsIds);

      final vipSongIds = resp.map((e) => e['song_id']).toSet();
      final filtered =
          songsIds.where((id) => !vipSongIds.contains(id)).toList();

      return Right(filtered);
    } catch (e, stackTrace) {
      log('Failed to fetch vip songs: $e', stackTrace: stackTrace, level: 1000);
      return Left(e.toString());
    }
  }

  Future<Either<String, bool>> isNonVipSong(String songId) async {
    final check = await filterNonVipSongs([songId]);
    return check.fold((l) => Left(l), (r) => Right(r.isNotEmpty));
  }

  Future<Either<String, Null>> addSongToVip(String songId) async {
    try {
      await _client.from('vip_songs').upsert({
        'song_id': songId,
      }, ignoreDuplicates: true);
      return Right(null);
    } catch (e, stackTrace) {
      log('Failed to add song to vip: $e', stackTrace: stackTrace, level: 1000);
      return Left(e.toString());
    }
  }
}
