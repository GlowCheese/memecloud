import 'dart:developer';

import 'package:memecloud/apis/supabase/main.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/apis/others/connectivity.dart';
import 'package:memecloud/models/playlist_model.dart';
import 'package:memecloud/models/song_model.dart';
import 'package:memecloud/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseUserPlaylistApi {
  final SupabaseClient _client;
  final String userPlaylistTable = 'user_playlists';
  final String userPlaylistSongsTable = 'user_playlist_songs';

  final String sampleImageLink = "assets/icons/playlist.webp";

  final _connectivity = getIt<ConnectivityStatus>();

  SupabaseUserPlaylistApi(this._client);

  //GET: getUserPlaylists
  Future<List<PlaylistModel>> getUserPlaylists() async {
    try {
      _connectivity.ensure();
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not found');
      final response = await _client
          .from(userPlaylistTable)
          .select('''
    id,
    title,
    description,
    thumbnail_url,
    users ( *), 
    $userPlaylistSongsTable (
      songs (
        *
      )
    )
  ''')
          .eq('user_id', user.id);

      final playlists =
          response
              .map(
                (e) => PlaylistModel.userPlaylist(
                  user: UserModel.fromJson(e['users']),
                  id: e['id'].toString(),
                  title: e['title'],
                  description: e['description'],
                  thumbnailUrl: e['thumbnail_url'] ?? sampleImageLink,
                  songs:
                      (e['user_playlist_songs'] as List<dynamic>?)
                          ?.map(
                            (e) => SongModel.fromJson<SupabaseApi>(e['songs']),
                          )
                          .toList() ??
                      [],
                ),
              )
              .toList();
      log('${playlists.length}');
      return playlists;
    } catch (e, stackTrace) {
      _connectivity.reportCrash(e, StackTrace.current);
      log(
        "Failed to get user playlists: $e",
        stackTrace: stackTrace,
        level: 1000,
      );
      rethrow;
    }
  }

  Future<PlaylistModel> getPlaylistInfo(String playlistId) async {
    try {
      _connectivity.ensure();
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not found');
      final response = await _client
          .from(userPlaylistTable)
          .select('''
    id,
    title,
    description,
    thumbnail_url,
    users ( *), 
    $userPlaylistSongsTable (
      songs (
        *
      )
    )
  ''')
          .eq('id', playlistId)
          .eq('user_id', user.id);

      final playlist =
          response
              .map(
                (e) => PlaylistModel.userPlaylist(
                  user: UserModel.fromJson(e['users']),
                  id: e['id'].toString(),
                  title: e['title'],
                  description: e['description'],
                  thumbnailUrl: e['thumbnail_url'] ?? sampleImageLink,
                  songs:
                      (e['user_playlist_songs'] as List<dynamic>?)
                          ?.map(
                            (e) => SongModel.fromJson<SupabaseApi>(e['songs']),
                          )
                          .toList() ??
                      [],
                ),
              )
              .toList();
      return playlist[0];
    } catch (e, stackTrace) {
      _connectivity.reportCrash(e, StackTrace.current);
      log(
        "Failed to get user playlists: $e",
        stackTrace: stackTrace,
        level: 1000,
      );
      rethrow;
    }
  }

  //PUT: createNewPlaylist
  Future<PlaylistModel> createNewPlaylist({
    required String title,
    required String description,
  }) async {
    try {
      _connectivity.ensure();
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not found');
      final newPlaylist =
          await _client
              .from(userPlaylistTable)
              .insert({
                'title': title,
                'user_id': user.id,
                'description': description,
              })
              .select()
              .single();
      return PlaylistModel.createNewPlaylistAtBottomSheet(newPlaylist);
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
    required String title,
    required String description,
  }) async {
    try {
      _connectivity.ensure();
      await _client
          .from(userPlaylistTable)
          .update({'title': title, 'description': description})
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
      await _client.from(userPlaylistTable).delete().eq('id', playlistId);
    } catch (e, stackTrace) {
      _connectivity.reportCrash(e, StackTrace.current);
      log("Failed to delete playlist: $e", stackTrace: stackTrace, level: 1000);
      rethrow;
    }
  }

  Future<String> addSongToPlaylist({
    required String playlistId,
    required String songId,
  }) async {
    try {
      _connectivity.ensure();
      final existingEntry =
          await _client
              .from(userPlaylistSongsTable)
              .select('*')
              .eq('playlist_id', playlistId)
              .eq('song_id', songId)
              .maybeSingle();

      if (existingEntry != null) {
        log('Song already in playlist, skipping insert.');
        return "Bài hát đã có trong playlist";
      }
      final position =
          await _client
              .from(userPlaylistSongsTable)
              .select('position')
              .eq('playlist_id', playlistId)
              .order('position', ascending: false)
              .limit(1)
              .maybeSingle();
      log('position: ${position?['position']}');
      await _client.from(userPlaylistSongsTable).insert({
        'playlist_id': playlistId,
        'song_id': songId,
        'position': (position?['position'] ?? 0) + 1,
      });
      return "Thêm thành công";
    } catch (e, stackTrace) {
      _connectivity.reportCrash(e, StackTrace.current);
      log(
        "Failed to add song to playlist: $e",
        stackTrace: stackTrace,
        level: 1000,
      );
      return "Thêm thất bại";
    }
  }

  Future<void> removeSongFromPlaylist({
    required String playlistId,
    required String songId,
  }) async {
    try {
      _connectivity.ensure();
      await _client
          .from(userPlaylistSongsTable)
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
