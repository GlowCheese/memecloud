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

  Future<List<SongModel>> getLikedSongsList() async {
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

  Future<void> toggleBlacklist(String songId) async {
    try {
      _connectivity.ensure();
      final userId = _client.auth.currentUser!.id;

      bool alreadyBlacklisted = await isBlacklisted(songId);

      if (alreadyBlacklisted) {
        await _client
            .from('blacklist')
            .delete()
            .eq('user_id', userId)
            .eq('song_id', songId);
      } else {
        await _client.from('blacklist').insert({
          'user_id': userId,
          'song_id': songId,
        });
      }
    } catch (e, stackTrace) {
      _connectivity.reportCrash(e, stackTrace);
      log(
        "Failed to toggle blacklist for song: $e",
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

  ///End blacklist song

  ///begin increment view
  Future<void> incrementView(String songId) async {
    final userId = Supabase.instance.client.auth.currentUser!.id;

    final response = await Supabase.instance.client.rpc(
      'increment_view',
      params: {'listened_song_id': songId, 'listened_user_id': userId},
    );

    if (response.error != null) {
      log('Lỗi tăng view: ${response.error!.message}');
    }
  }

  ///end increment view

  Future<List<String>> filterNonVipSongs(Iterable<String> songsIds) async {
    try {
      _connectivity.ensure();
      final resp = await _client
          .from('vip_songs')
          .select('song_id')
          .inFilter('song_id', songsIds.toList());

      final vipSongIds = resp.map((e) => e['song_id']).toSet();
      return songsIds.where((id) => !vipSongIds.contains(id)).toList();
    } catch (e, stackTrace) {
      _connectivity.reportCrash(e, StackTrace.current);
      log('Failed to fetch vip songs: $e', stackTrace: stackTrace, level: 1000);
      rethrow;
    }
  }

  Future<void> markSongAsVip(String songId) async {
    try {
      _connectivity.ensure();
      return await _client.from('vip_songs').upsert({
        'song_id': songId,
      }, ignoreDuplicates: true);
    } catch (e, stackTrace) {
      _connectivity.reportCrash(e, StackTrace.current);
      log(
        'Failed to mark song as vip: $e',
        stackTrace: stackTrace,
        level: 1000,
      );
      rethrow;
    }
  }

  Future<List<String>> getVipSongIds() async {
    try {
      _connectivity.ensure();
      final response = await _client.from('vip_songs').select('song_id');
      final songIds = List<String>.from(response.map((e) => e['song_id']));
      return songIds;
    } catch (e, stackTrace) {
      _connectivity.reportCrash(e, StackTrace.current);
      log(
        'Failed to fetch all vip songs: $e',
        stackTrace: stackTrace,
        level: 1000,
      );
      rethrow;
    }
  }
}
