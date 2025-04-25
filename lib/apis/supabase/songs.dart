import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:memecloud/models/song_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseSongsApi {
  final SupabaseClient _client;
  SupabaseSongsApi(this._client);

  @Deprecated(
    "This fetch the whole songs info repository and should not be used.",
  )
  Future<Either> fetchSongList() async {
    final userId = _client.auth.currentUser!.id;

    try {
      final response = await _client
          .from('songs')
          .select('''
            id,
            title,
            thumbnail_url,
            release_date,
            song_artists(
              artist:artists (
                name
              )
            ),
            liked_songs(user_id)
          ''')
          .limit(4);
      final songsList =
          (response as List<dynamic>).map((song) {
            final isLiked = (song['liked_songs'] as List).any(
              (like) => like['user_id'] == userId,
            );
            final artist =
                (song['song_artists'] as List).isNotEmpty
                    ? song['song_artists'][0]['artist']['name']
                    : 'Unknown Artist';
            final songMap = {
              'id': song['id'],
              'title': song['title'],
              'thumbnail_url': song['thumbnail_url'],
              'artist': artist,
              'release_date': song['release_date'],
              'is_liked': isLiked,
            };
            return SongModel.fromJson(songMap);
          }).toList();
      return Right(songsList);
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, String>> saveSongInfo(SongModel song) async {
    try {
      final releaseDate = song.releaseDate.toUtc().toIso8601String();
      await _client
          .from('songs')
          .upsert(
            {
              'id': song.id,
              'title': song.title,
              'thumbnail_url': song.thumbnailUrl,
              'release_date': releaseDate,
            },
            onConflict: 'id',
            ignoreDuplicates: true,
          );
      // await _client.from('song_artists').upsert({'song_id': song.id, 'artist_id': })
      return Right("ok");
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

  Future<Either> setIsLiked(String songId, bool isLiked) async {
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
      return Right("ok");
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either> getLikedSongsList() async {
    try {
      final userId = _client.auth.currentUser!.id;

      final response = await _client
          .from('liked_songs')
          .select('''songs(
            id,
            title,
            thumbnail_url,
            release_date,
            song_artists(
              artist:artists (
                name
              )
            )
          )''')
          .eq('user_id', userId);

      final songsList =
          (response as List).map((item) {
            final song = item['songs'];
            final artist =
                (song['song_artists'] as List).isNotEmpty
                    ? song['song_artists'][0]['artist']['name']
                    : 'Unknown Artist';
            final songMap = {
              'id': song['id'],
              'title': song['title'],
              'thumbnail_url': song['thumbnail_url'],
              'artist': artist,
              'release_date': song['release_date'],
              'is_liked': true,
            };
            return SongModel.fromJson(songMap);
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

  Future<Either<String, String>> addSongToVip(String songId) async {
    try {
      await _client.from('vip_songs').upsert({
        'song_id': songId,
      }, ignoreDuplicates: true);
      return Right("ok");
    } catch (e, stackTrace) {
      log('Failed to add song to vip: $e', stackTrace: stackTrace, level: 1000);
      return Left(e.toString());
    }
  }
}
