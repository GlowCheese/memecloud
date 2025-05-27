import 'dart:developer';

import 'package:memecloud/apis/others/connectivity.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/models/playlist_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabasePlaylistsApi {
  final SupabaseClient _client;
  SupabasePlaylistsApi(this._client);
  final _connectivity = getIt<ConnectivityStatus>();

  Future<void> savePlaylistInfo(PlaylistModel playlist) async {
    try {
      _connectivity.ensure();
      await _client.from('playlists').upsert(playlist.toJson(only: true));
    } catch (e, stackTrace) {
      _connectivity.reportCrash(e, StackTrace.current);
      log(
        "Failed to save playlist info: $e",
        stackTrace: stackTrace,
        level: 1000,
      );
      rethrow;
    }
  }

  Future<void> createNewPlaylist({
    required String playlistName,
    required String description,
  }) async {
    try {
      _connectivity.ensure();
      await _client.from('playlists').insert({
        'title': playlistName,
        'user_id': _client.auth.currentUser?.id,
        'description': description,
      });
    } catch (e, stackTrace) {
      _connectivity.reportCrash(e, StackTrace.current);
      log(
        "Failed to save playlist info: $e",
        stackTrace: stackTrace,
        level: 1000,
      );
      rethrow;
    }
  }

  Future<void> updatePlaylist({
    required String playlistId,
    required String playlistName,
    required String description,
  }) async {
    try {
      _connectivity.ensure();
      await _client
          .from('playlists')
          .update({'title': playlistName, 'description': description})
          .eq('id', playlistId);
    } catch (e, stackTrace) {
      _connectivity.reportCrash(e, StackTrace.current);
      log("Failed to update playlist: $e", stackTrace: stackTrace, level: 1000);
      rethrow;
    }
  }

  Future<void> deletePlaylist({required String playlistId}) async {
    try {
      _connectivity.ensure();
      await _client.from('playlists').delete().eq('id', playlistId);
    } catch (e, stackTrace) {
      _connectivity.reportCrash(e, StackTrace.current);
      log("Failed to delete playlist: $e", stackTrace: stackTrace, level: 1000);
      rethrow;
    }
  }

  Future<void> addSongToPlaylist({
    required String playlistId,
    required String songId,
  }) async {
    try {
      _connectivity.ensure();
      final position =
          await _client
              .from('playlist_songs')
              .select('position')
              .eq('playlist_id', playlistId)
              .order('position', ascending: false)
              .limit(1)
              .single();
      await _client.from('playlist_songs').insert({
        'playlist_id': playlistId,
        'song_id': songId,
        'position': (position['position'] ?? 0) + 1,
      });
    } catch (e, stackTrace) {
      _connectivity.reportCrash(e, StackTrace.current);
      log(
        "Failed to add song to playlist: $e",
        stackTrace: stackTrace,
        level: 1000,
      );
      rethrow;
    }
  }

  Future<void> removeSongFromPlaylist({
    required String playlistId,
    required String songId,
  }) async {
    try {
      _connectivity.ensure();
      await _client
          .from('playlist_songs')
          .delete()
          .eq('playlist_id', playlistId)
          .eq('song_id', songId);
    } catch (e, stackTrace) {
      _connectivity.reportCrash(e, StackTrace.current);
      log(
        "Failed to remove song from playlist: $e",
        stackTrace: stackTrace,
        level: 1000,
      );
      rethrow;
    }
  }
}
