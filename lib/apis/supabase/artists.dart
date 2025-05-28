import 'dart:io';
import 'dart:developer';
import 'package:memecloud/apis/supabase/main.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:memecloud/models/artist_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:memecloud/apis/others/connectivity.dart';

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

  Future<int> newArtistStream(String artistId) async {
    try {
      _connectivity.ensure();
      final response = await _client.rpc(
        'new_artist_stream',
        params: {'artist_id': artistId},
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

  Future<int> streamCount(String artistId) async {
    try {
      _connectivity.ensure();
      final response =
          await _client
              .from('artists')
              .select('stream_count')
              .eq('id', artistId)
              .maybeSingle();
      return response?['stream_count'] ?? 0;
    } catch (e, stackTrace) {
      _connectivity.reportCrash(e, stackTrace);
      log(
        'Failed to count artist streams: $e',
        stackTrace: stackTrace,
        level: 1000,
      );
      rethrow;
    }
  }

  Future<List<ArtistModel>> getTopArtists({required int count}) async {
    try {
      _connectivity.ensure();
      final response = await _client
          .from('artists')
          .select('*')
          .order('stream_count', ascending: false)
          .limit(count);
      return response
          .map((e) => ArtistModel.fromJson<SupabaseApi>({'artist': e}))
          .toList();
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

  // follow artist
  Future<void> toggleFollowArtist(String artistId) async {
    try {
      _connectivity.ensure();
      final userId = getIt<ApiKit>().currentSession()?.user.id;
      if (userId == null) {
        throw Exception('User not logged in');
      }
      final response = await _client
          .from('artist_followers')
          .select()
          .eq('user_id', userId)
          .eq('artist_id', artistId);
      if (response.isNotEmpty) {
        await _client
            .from('artist_followers')
            .delete()
            .eq('user_id', userId)
            .eq('artist_id', artistId);
      } else {
        await _client.from('artist_followers').insert({
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
    log("Checking if user $userId is following artist $artistId");
    final response = await _client
        .from('artist_followers')
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
              .from('artist_followers')
              .select()
              .eq('artist_id', artistId)
              .count();
      return response.count;
    } catch (e, stackTrace) {
      _connectivity.reportCrash(e, StackTrace.current);
      log(
        "Failed to get artist artist_followers count: $e",
        stackTrace: stackTrace,
        level: 1000,
      );
      rethrow;
    }
  }

  Future<List<ArtistModel>> getFollowedArtists() async {
    try {
      _connectivity.ensure();
      final userId = getIt<ApiKit>().currentSession()?.user.id;
      if (userId == null) {
        throw Exception('Chưa đăng nhập');
      }
      final response = await _client
          .from('artist_followers')
          .select('artist_id')
          .eq('user_id', userId);
      final artistIds = response.map((e) => e['artist_id']).toList();
      final artistsResponse = await _client
          .from('artists')
          .select('*')
          .inFilter('id', artistIds);
      return artistsResponse
          .map((e) => ArtistModel.fromJson<SupabaseApi>({'artist': e}))
          .toList();
    } catch (e, stackTrace) {
      _connectivity.reportCrash(e, stackTrace);
      log(
        "Failed to get followed artists: $e",
        stackTrace: stackTrace,
        level: 1000,
      );
      rethrow;
    }
  }

  Future<List<ArtistModel>> getAllArtists({
    required int offset,
    required int limit,
  }) async {
    sleep(const Duration(milliseconds: 500));
    try {
      _connectivity.ensure();
      final userId = getIt<ApiKit>().currentSession()?.user.id;
      if (userId == null) {
        throw Exception('Chưa đăng nhập');
      }
      final response = await _client
          .from('artists')
          .select('*')
          .range(offset, offset + limit - 1);
      final List<ArtistModel> allArtist =
          response
              .map((e) => ArtistModel.fromJson<SupabaseApi>({'artist': e}))
              .toList();
      return allArtist;
    } catch (e, stackTrace) {
      _connectivity.reportCrash(e, stackTrace);
      log(
        "Failed to get followed artists: $e",
        stackTrace: stackTrace,
        level: 1000,
      );
      rethrow;
    }
  }

  Future<List<ArtistModel>> getAllArtistsWithQuery(String query) async {
    try {
      _connectivity.ensure();
      final userId = getIt<ApiKit>().currentSession()?.user.id;
      if (userId == null) {
        throw Exception('Chưa đăng nhập');
      }
      query = query.toLowerCase();
      final response = await _client
          .from('artists')
          .select('*')
          .like('name', '%$query%');
      final List<ArtistModel> allArtist =
          response
              .map((e) => ArtistModel.fromJson<SupabaseApi>({'artist': e}))
              .toList();
      return allArtist;
    } catch (e, stackTrace) {
      _connectivity.reportCrash(e, stackTrace);
      log(
        "Failed to get followed artists: $e",
        stackTrace: stackTrace,
        level: 1000,
      );
      rethrow;
    }
  }
}
