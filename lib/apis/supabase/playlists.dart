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
      await _client
          .from('playlists')
          .upsert(
            playlist.toJson(only: true)
          );
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
}