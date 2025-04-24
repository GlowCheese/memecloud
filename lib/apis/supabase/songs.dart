import 'package:dartz/dartz.dart';
import 'package:memecloud/models/song_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseSongsApi {
  final SupabaseClient _client;
  SupabaseSongsApi(this._client);

  Future<Either> fetchSongList() async {
    final userId = _client.auth.currentUser!.id;

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
            ),
            liked_songs(user_id)
          ''')
          .limit(4);
      final songsList =
          (response as List<dynamic>).map((song) {
            final isLiked = (song['liked_songs'] as List).any(
              (like) => like['user_id'] == userId,
            );
            final artist = (song['song_artists'] as List).isNotEmpty
              ? song['song_artists'][0]['artist']['name']
              : 'Unknown';
            final songMap = {
              'id': song['id'],
              'title': song['title'],
              'url': song['url'],
              'thumbnail_url': song['thumbnail_url'],
              'artist': artist,
              'is_liked': isLiked,
            };
            return SongModel.fromJson(songMap);
          }).toList();
      return Right(songsList);
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either> setLike(String songId, bool isLiked) async {
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
            url,
            thumbnail_url,
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
            final artist = (song['song_artists'] as List).isNotEmpty
              ? song['song_artists'][0]['artist']['name']
              : 'Unknown';
            final songMap = {
              'id': song['id'],
              'title': song['title'],
              'url': song['url'],
              'thumbnail_url': song['thumbnail_url'],
              'artist': artist,
              'is_liked': true,
            };
            return SongModel.fromJson(songMap);
          }).toList();

      return Right(songsList);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
