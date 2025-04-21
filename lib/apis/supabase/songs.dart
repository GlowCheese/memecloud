import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:memecloud/models/song_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseSongsApi {
  final SupabaseClient _client;
  SupabaseSongsApi(this._client);

  Future<Either> fetchSongList() async {
    try {
      final response = await _client
          .from('songs')
          .select('id, title, cover_url, url, artists!inner (name)')
          .limit(4);
      final songsList =
          (response as List<dynamic>).map((song) {
            final songMap = {
              'id': song['id'],
              'title': song['title'],
              'url': song['url'],
              'cover_url': song['cover_url'],
              'artist': song['artists'][0]['name'],
            };
            return SongModel.fromJson(songMap);
          }).toList();
      return Right(songsList);
    } catch (e) {
      debugPrint('Error parsing songs: $e');
      return Left(e.toString());
    }
  }
}
