import 'package:dartz/dartz.dart';
import 'package:memecloud/data/models/song/song_dto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class SongService {
  Future<Either> fetchSongList();
}

class SongSupabaseService extends SongService {
  final _supabaseClient = Supabase.instance.client;
  @override
  Future<Either> fetchSongList() async {
    try {
      final response = await _supabaseClient
        .from('songs')
        .select('''
      id,
      title,
      cover_url,
      url,
      artists!inner (
      name
      )
      ''')
        .limit(4);
      final songsList = (response as List<dynamic>).map((song) {
        final songMap = {
          'id': song['id'],
          'title': song['title'],
          'url': song['url'],
          'cover_url': song['cover_url'],
          'artist': song['artists'][0]['name'],
        };
        return SongDto.fromJson(songMap);
      }).toList();
      return Right(songsList);
    } catch (e) {
      print('Error parsing songs: $e');
      return Left(e.toString());
    }
  }
}
