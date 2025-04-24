import 'package:dartz/dartz.dart';
import 'package:memecloud/models/song_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseSongsApi {
  final SupabaseClient _client;
  SupabaseSongsApi(this._client);

  Future<Either> fetchSongList() async {
    try {
      final response = await _client
          .from('songs')
          .select('''
            id,
            title,
            url,
            thumbnail_url,
            song_artists(
              artist:artists (
                name
              )
            )
          ''')
          .limit(4);
      final songsList =
          (response as List<dynamic>).map((song) {
            final songMap = {
              'id': song['id'],
              'title': song['title'],
              'url': song['url'],
              'thumbnail_url': song['thumbnail_url'],
              'artist': song['song_artists'][0]['artist']['name'],
            };
            return SongModel.fromJson(songMap);
          }).toList();
      return Right(songsList);
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either> toggleLike(String songId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        return Left('User not authenticated');
      }

      final likedResponse =
          await _client
              .from('liked_songs')
              .select()
              .eq('song_id', songId)
              .eq('user_id', userId)
              .maybeSingle();

      if (likedResponse == null) {
        final response =
            await _client.from('liked_songs').insert({
              'song_id': songId,
              'user_id': userId,
            }).select();
        return Right(response);
      } else {
        final response =
            await _client
                .from('liked_songs')
                .delete()
                .eq('song_id', songId)
                .eq('user_id', userId)
                .select();
        return Right(response);
      }
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either> getLikedSongsList() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        return Left('User not authenticated');
      }

      final response = await _client
          .from('liked_songs')
          .select('songs(*)')
          .eq('user_id', userId);

      final songsList =
          (response as List).map((item) {
            final song = item['songs'];
            final songMap = {
              'id': song['id'],
              'title': song['title'],
              'artist': song['artist'],
              'cover_url': song['cover_url'],
              'audio_url': song['audio_url'],
              'is_liked': true, // Since these are liked songs
            };
            return SongModel.fromJson(songMap);
          }).toList();

      return Right(songsList);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
