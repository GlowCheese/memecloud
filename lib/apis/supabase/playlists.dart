import 'dart:developer';

import 'package:memecloud/apis/others/connectivity.dart';
import 'package:memecloud/apis/supabase/main.dart';
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

  Future<void> setIsFollowed(String playlistId, bool isFollowed) async {
    try {
      _connectivity.ensure();
      final userId = _client.auth.currentUser!.id;

      if (isFollowed) {
        await _client
            .from('followed_playlists')
            .upsert(
              {'user_id': userId, 'playlist_id': playlistId},
              onConflict: 'user_id,playlist_id',
              ignoreDuplicates: true,
            );
      } else {
        await _client.from('followed_playlists').delete().match({
          'user_id': userId,
          'playlist_id': playlistId,
        });
      }
    } catch (e, stackTrace) {
      _connectivity.reportCrash(e, StackTrace.current);
      log("Failed to follow playlist: $e", stackTrace: stackTrace, level: 1000);
      rethrow;
    }
  }

  Future<List<PlaylistModel>> getFollowedPlaylists() async {
    try {
      _connectivity.ensure();
      final userId = _client.auth.currentUser!.id;
      final response = await _client
          .from('followed_playlists')
          .select('playlists(*)')
          .eq('user_id', userId);

      final playlistsList =
          response
              .map((e) => PlaylistModel.fromJson<SupabaseApi>(e['playlists']))
              .toList();

      return playlistsList;
    } catch (e, stackTrace) {
      _connectivity.reportCrash(e, StackTrace.current);
      log("Failed to get liked songs: $e", stackTrace: stackTrace, level: 1000);
      rethrow;
    }
  }

  Future<int> getPlaylistFollowerCounts(String playlistId) async {
    try {
      _connectivity.ensure();
      final response = await _client
          .from('followed_playlists')
          .select('user_id')
          .eq('playlist_id', playlistId)
          .count(CountOption.estimated);
      return response.count;
    } catch (e, stackTrace) {
      _connectivity.reportCrash(e, StackTrace.current);
      log(
        "Failed to get playlist followers count: $e",
        stackTrace: stackTrace,
        level: 1000,
      );
      rethrow;
    }
  }

  Future<List<PlaylistModel>> getSuggestedPlaylists() async {
    try {
      _connectivity.ensure();
      final response = await _client.from('playlists').select('*').limit(10);
      return response
          .map((e) => PlaylistModel.fromJson<SupabaseApi>(e))
          .toList();
    } catch (e, stackTrace) {
      _connectivity.reportCrash(e, StackTrace.current);
      log(
        "Failed to get suggested playlists: $e",
        stackTrace: stackTrace,
        level: 1000,
      );
      rethrow;
    }
  }
}
