import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:memecloud/apis/supabase/main.dart';
import 'package:memecloud/models/artist_model.dart';
import 'package:memecloud/models/song_model.dart';
import 'package:memecloud/utils/common.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseSongsApi {
  final SupabaseClient _client;
  SupabaseSongsApi(this._client);

  Future<Either<String, String>> saveSongInfo(SongModel song) async {
    final releaseDate = song.releaseDate.toUtc().toIso8601String();
    try {
      try {
        await _client.from('songs').insert({
          'id': song.id,
          'title': song.title,
          'artists_names': song.artistsNames,
          'thumbnail_url': song.thumbnailUrl,
          'release_date': releaseDate,
        });
        return (await saveSongArtists(
          song.id,
          song.artists,
        )).fold((l) => throw l, (r) => Right("ok"));
      } on PostgrestException {
        return Right("ok");
      }
    } catch (e, stackTrace) {
      log("Failed to save song info: $e", stackTrace: stackTrace, level: 1000);
      return Left(e.toString());
    }
  }

  Future<Either<String, String>> saveSongArtists(
    String songId,
    List<ArtistModel> artists,
  ) async {
    try {
      (await saveArtistsInfo(artists)).fold((l) => throw l, (r) {});
      try {
        await _client
            .from('song_artists')
            .insert(
              artists.map(
                (artist) => {'song_id': songId, 'artist_id': artist.id},
              ).toList(),
            );
        return Right("ok");
      } on PostgrestException {
        return Right("ok");
      }
    } catch (e, stackTrace) {
      log(
        "Failed to save artist info: $e",
        stackTrace: stackTrace,
        level: 1000,
      );
      return Left(e.toString());
    }
  }

  Future<Either<String, String>> saveArtistsInfo(
    List<ArtistModel> artists,
  ) async {
    try {
      await _client
          .from('artists')
          .upsert(
            artists
                .map(
                  (artist) => ignoreNullValuesOfMap({
                    'id': artist.id,
                    'name': artist.name,
                    'alias': artist.alias,
                    'thumbnail_url': artist.thumbnailUrl,
                    'playlist_id': artist.playlistId,

                    'realname': artist.realname,
                    'bio': artist.biography,
                    'short_bio': artist.shortBiography,
                  }),
                )
                .toList(),
          );
      return Right("ok");
    } catch (e, stackTrace) {
      log(
        "Failed to save artist info: $e",
        stackTrace: stackTrace,
        level: 1000,
      );
      return Left(e.toString());
    }
  }

  Future<Either<String, bool>> getIsLiked(String songId) async {
    try {
      final userId = _client.auth.currentUser!.id;
      final response =
          await _client
              .from('liked_songs')
              .select('song_id')
              .eq('user_id', userId)
              .eq('song_id', songId)
              .maybeSingle();
      return Right(response != null);
    } catch (e, stackTrace) {
      log('Failed to getIsLiked: $e', stackTrace: stackTrace, level: 1000);
      return Left(e.toString());
    }
  }

  Future<Either> setIsLiked(String songId, bool isLiked) async {
    try {
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
      return Right("ok");
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either> getLikedSongsList() async {
    try {
      final userId = _client.auth.currentUser!.id;

      final response = await _client
          .from('liked_songs')
          .select('''songs(
            *,
            song_artists(
              artist:artists (*)
            )
          )''')
          .eq('user_id', userId);

      final songsList =
          (response as List).map((item) {
            return SongModel.fromJson<SupabaseApi>(
              item['songs'],
              isLiked: true,
            );
          }).toList();

      return Right(songsList);
    } catch (e, stackTrace) {
      log("Failed to get liked songs: $e", stackTrace: stackTrace, level: 1000);
      return Left(e.toString());
    }
  }

  Future<Either<String, List>> filterNonVipSongs(List songsIds) async {
    try {
      final resp = await _client
          .from('vip_songs')
          .select('song_id')
          .inFilter('song_id', songsIds);

      final vipSongIds = resp.map((e) => e['song_id']).toSet();
      final filtered =
          songsIds.where((id) => !vipSongIds.contains(id)).toList();

      return Right(filtered);
    } catch (e, stackTrace) {
      log('Failed to fetch vip songs: $e', stackTrace: stackTrace, level: 1000);
      return Left(e.toString());
    }
  }

  Future<Either<String, bool>> isNonVipSong(String songId) async {
    final check = await filterNonVipSongs([songId]);
    return check.fold((l) => Left(l), (r) => Right(r.isNotEmpty));
  }

  Future<Either<String, String>> addSongToVip(String songId) async {
    try {
      await _client.from('vip_songs').upsert({
        'song_id': songId,
      }, ignoreDuplicates: true);
      return Right("ok");
    } catch (e, stackTrace) {
      log('Failed to add song to vip: $e', stackTrace: stackTrace, level: 1000);
      return Left(e.toString());
    }
  }
}
