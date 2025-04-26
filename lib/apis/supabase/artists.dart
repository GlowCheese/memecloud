import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:memecloud/models/artist_model.dart';
import 'package:memecloud/utils/common.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseArtistsApi {
  final SupabaseClient _client;
  SupabaseArtistsApi(this._client);

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

  Future<Either<String, Null>> saveSongArtists(
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
        return Right(null);
      } on PostgrestException {
        return Right(null);
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
}