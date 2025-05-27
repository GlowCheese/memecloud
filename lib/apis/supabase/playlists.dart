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
}
