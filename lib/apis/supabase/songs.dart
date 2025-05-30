import 'dart:io';
import 'dart:developer';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/models/song_model.dart';
import 'package:memecloud/apis/others/connectivity.dart';
import 'package:memecloud/apis/supabase/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseSongsApi {
  final SupabaseClient _client;
  final _connectivity = getIt<ConnectivityStatus>();
  SupabaseSongsApi(this._client);

  Future<void> saveSongInfo(SongModel song) async {
    try {
      _connectivity.ensure();
      await _client.from('songs').upsert(song.toJson(only: true));
    } catch (e, stackTrace) {
      _connectivity.reportCrash(e, StackTrace.current);
      log('Failed to save song info: $e', stackTrace: stackTrace, level: 1000);
      rethrow;
    }
  }

  Future<bool> getIsLiked(String songId) async {
    try {
      _connectivity.ensure();
      final userId = _client.auth.currentUser!.id;
      final response =
          await _client
              .from('liked_songs')
              .select('song_id')
              .eq('user_id', userId)
              .eq('song_id', songId)
              .maybeSingle();
      return response != null;
    } catch (e, stackTrace) {
      _connectivity.reportCrash(e, StackTrace.current);
      log('Failed to getIsLiked: $e', stackTrace: stackTrace, level: 1000);
      rethrow;
    }
  }

  Future<SongModel?> getSongInfo(String songId) async {
    try {
      _connectivity.ensure();
      final response =
          await _client
              .from('songs')
              .select('*, song_artists(artist:artists (*))')
              .eq('id', songId)
              .maybeSingle();
      if (response == null) return null;
      return SongModel.fromJson<SupabaseApi>(response);
    } catch (e, stackTrace) {
      _connectivity.reportCrash(e, StackTrace.current);
      log('Failed to getSongInfo: $e', stackTrace: stackTrace, level: 1000);
      rethrow;
    }
  }

  Future<void> setIsLiked(String songId, bool isLiked) async {
    try {
      _connectivity.ensure();
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
    } catch (e, stackTrace) {
      _connectivity.reportCrash(e, StackTrace.current);
      log("Failed to like a song: $e", stackTrace: stackTrace, level: 1000);
      rethrow;
    }
  }

  Future<List<SongModel>> getLikedSongs() async {
    try {
      _connectivity.ensure();
      final userId = _client.auth.currentUser!.id;

      final response = await _client
          .from('liked_songs')
          .select('songs(*, song_artists(artist:artists (*)))')
          .eq('user_id', userId);

      final songsList =
          (response as List).map((item) {
            return SongModel.fromJson<SupabaseApi>(item['songs']);
          }).toList();

      return songsList;
    } catch (e, stackTrace) {
      _connectivity.reportCrash(e, StackTrace.current);
      log("Failed to get liked songs: $e", stackTrace: stackTrace, level: 1000);
      rethrow;
    }
  }

  ///Start blacklist song
  Future<bool> isBlacklisted(String songId) async {
    try {
      _connectivity.ensure();
      final userId = _client.auth.currentUser!.id;
      final existing =
          await _client
              .from('blacklist')
              .select('song_id')
              .eq('user_id', userId)
              .eq('song_id', songId)
              .maybeSingle();
      return existing != null;
    } catch (e, stackTrace) {
      _connectivity.reportCrash(e, StackTrace.current);
      log(
        "Failed to get blacklist state: $e",
        stackTrace: stackTrace,
        level: 1000,
      );
      rethrow;
    }
  }

  Future<void> setIsBlacklisted(String songId, bool isBlacklisted) async {
    try {
      _connectivity.ensure();
      final userId = _client.auth.currentUser!.id;

      if (isBlacklisted) {
        await _client.from('blacklist').insert({
          'user_id': userId,
          'song_id': songId,
        });
      } else {
        await _client
            .from('blacklist')
            .delete()
            .eq('user_id', userId)
            .eq('song_id', songId);
      }
    } catch (e, stackTrace) {
      _connectivity.reportCrash(e, stackTrace);
      log(
        "Failed to set blacklist for song: $e",
        stackTrace: stackTrace,
        level: 1000,
      );
      rethrow;
    }
  }

  Future<List<SongModel>> getBlacklistSongs() async {
    try {
      _connectivity.ensure();
      final userId = _client.auth.currentUser!.id;

      final response = await _client
          .from('blacklist')
          .select('songs(*, song_artists(artist:artists (*)))')
          .eq('user_id', userId);

      final songsList =
          response
              .map((e) => SongModel.fromJson<SupabaseApi>(e['songs']))
              .toList();
      return songsList;
    } catch (e, stackTrace) {
      _connectivity.reportCrash(e, stackTrace);
      log(
        "Failed to get blacklisted songs: $e",
        stackTrace: stackTrace,
        level: 1000,
      );
      rethrow;
    }
  }

  Future<int> newSongStream(String songId) async {
    try {
      _connectivity.ensure();
      final response = await _client.rpc(
        'new_song_stream',
        params: {'song_id': songId},
      );
      return response as int;
    } catch (e, stackTrace) {
      _connectivity.reportCrash(e, stackTrace);
      log(
        'Failed to record new song stream: $e',
        stackTrace: stackTrace,
        level: 1000,
      );
      rethrow;
    }
  }

  Future<int> streamCount(String songId) async {
    try {
      _connectivity.ensure();
      final response =
          await _client
              .from('songs')
              .select('stream_count')
              .eq('id', songId)
              .maybeSingle();
      return response?['stream_count'] ?? 0;
    } catch (e, stackTrace) {
      _connectivity.reportCrash(e, stackTrace);
      log('Failed to count song streams', stackTrace: stackTrace, level: 1000);
      rethrow;
    }
  }

  Future<List<SongModel>> getFollowedArtistsSongs() async {
    try {
      _connectivity.ensure();
      final userId = _client.auth.currentUser!.id;

      final response = await _client
          .from('artist_followers')
          .select(
            'artist_id, artist:artists(*, song_artists(*, song:songs(*)))',
          )
          .eq('user_id', userId);

      final songsList = <SongModel>[];
      for (final artist in response) {
        for (final song in artist['artist']['songs']) {
          songsList.add(SongModel.fromJson<SupabaseApi>(song));
        }
      }
      return songsList;
    } catch (e, stackTrace) {
      _connectivity.reportCrash(e, StackTrace.current);
      log(
        'Failed to get followed artists songs: $e',
        stackTrace: stackTrace,
        level: 1000,
      );
      rethrow;
    }
  }

  Future<List<SongModel>> getSongsPage({
    required int page,
    required int limit,
  }) async {
    try {
      sleep(const Duration(milliseconds: 1500));
      final response = await _client
          .from('songs')
          .select('*')
          .range(page * limit, (page + 1) * limit - 1);

      List<SongModel> songs =
          response.map((e) => SongModel.fromJson<SupabaseApi>(e)).toList();

      return songs;
    } catch (e, stackTrace) {
      log(
        'Failed to get songs page $page: $e',
        stackTrace: stackTrace,
        level: 1000,
      );
      rethrow;
    }
  }
}
