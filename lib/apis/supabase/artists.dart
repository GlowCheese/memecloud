import 'dart:developer';
import 'package:memecloud/apis/apikit.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/apis/supabase/main.dart';
import 'package:memecloud/apis/others/connectivity.dart';
import 'package:memecloud/models/artist_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseArtistsApi {
  final SupabaseClient _client;
  SupabaseArtistsApi(this._client);
  final _connectivity = getIt<ConnectivityStatus>();

  Future<void> saveArtistsInfo(List<ArtistModel> artists) async {
    try {
      _connectivity.ensure();
      await _client
          .from('artists')
          .upsert(artists.map((artist) => artist.toJson()['artist']).toList());
    } catch (e, stackTrace) {
      _connectivity.reportCrash(e, StackTrace.current);
      log(
        "Failed to save artist info: $e",
        stackTrace: stackTrace,
        level: 1000,
      );
      rethrow;
    }
  }

  Future<void> saveSongArtists(String songId, List<ArtistModel> artists) async {
    try {
      _connectivity.ensure();
      await saveArtistsInfo(artists);
      await _client
          .from('song_artists')
          .upsert(
            artists
                .map((artist) => {'song_id': songId, 'artist_id': artist.id})
                .toList(),
          );
    } catch (e, stackTrace) {
      _connectivity.reportCrash(e, StackTrace.current);
      log(
        "Failed to save artist info: $e",
        stackTrace: stackTrace,
        level: 1000,
      );
      rethrow;
    }
  }

  Future<List<ArtistModel>> getTopArtists(int count) async {
    try {
      _connectivity.ensure();
      final response = await _client
          .from('artists')
          .select()
          .order('view_in_week', ascending: false)
          .limit(count);

      return response
          .map(
            (artist) => ArtistModel.fromJson<SupabaseApi>({'artist': artist}),
          )
          .toList();
    } catch (e, stackTrace) {
      _connectivity.reportCrash(e, StackTrace.current);
      log("Failed to get top artists: $e", stackTrace: stackTrace, level: 1000);
      rethrow;
    }
  }

  //follow artist
  Future<void> toggleFollowArtist(String artistId) async {
    try {
      _connectivity.ensure();
      final userId = getIt<ApiKit>().currentSession()?.user.id;
      if (userId == null) {
        throw Exception('User not logged in');
      }
      final response = await _client
          .from('followers')
          .select()
          .eq('user_id', userId)
          .eq('artist_id', artistId);
      if (response.isNotEmpty) {
        await _client
            .from('followers')
            .delete()
            .eq('user_id', userId)
            .eq('artist_id', artistId);
      } else {
        await _client.from('followers').insert({
          'user_id': userId,
          'artist_id': artistId,
        });
      }
    } catch (e, stackTrace) {
      _connectivity.reportCrash(e, StackTrace.current);
      log("Failed to follow artist: $e", stackTrace: stackTrace, level: 1000);
      rethrow;
    }
  }

  Future<bool> isFollowingArtist(String artistId) async {
    final userId = getIt<ApiKit>().currentSession()?.user.id;
    if (userId == null) {
      return false;
    }
    final response = await _client
        .from('followers')
        .select()
        .eq('user_id', userId)
        .eq('artist_id', artistId);
    return response.isNotEmpty;
  }

  Future<int> getArtistFollowersCount(String artistId) async {
    try {
      _connectivity.ensure();
      final response =
          await _client
              .from('followers')
              .select()
              .eq('artist_id', artistId)
              .count();
      return response.count;
    } catch (e, stackTrace) {
      _connectivity.reportCrash(e, StackTrace.current);
      log(
        "Failed to get artist followers count: $e",
        stackTrace: stackTrace,
        level: 1000,
      );
      rethrow;
    }
  }
}
