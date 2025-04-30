import 'dart:async';

import 'package:just_audio_background/just_audio_background.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:memecloud/apis/supabase/main.dart';
import 'package:memecloud/apis/zingmp3/endpoints.dart';
import 'package:memecloud/blocs/liked_songs/liked_songs_cubit.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/models/artist_model.dart';

class SongModel {
  final String id;
  final String title;
  final String artistsNames;
  final String thumbnailUrl;
  final DateTime releaseDate;
  final List<ArtistModel> artists;
  bool? isLiked;

  // Private constructor
  SongModel._({
    required this.id,
    required this.title,
    required this.artistsNames,
    required this.artists,
    required this.releaseDate,
    required this.thumbnailUrl,
    this.isLiked,
  });

  static SongModel fromJson<T>(Map<String, dynamic> json, {bool? isLiked}) {
    if (T == ZingMp3Api) {
      return SongModel._(
        id: json['encodeId'],
        title: json['title'],
        artistsNames: json['artistsNames'],
        thumbnailUrl: json['thumbnailM'] ?? json['thumbnail'],
        releaseDate: DateTime.fromMillisecondsSinceEpoch(
          json['releaseDate'] * 1000,
        ),
        artists: !json.containsKey('artists') ? [] : ArtistModel.fromListJson<T>(json['artists']),
        isLiked: isLiked,
      );
    } else if (T == SupabaseApi) {
      return SongModel._(
        id: json['id'],
        title: json['title'],
        artistsNames: json['artists_names'],
        artists: ArtistModel.fromListJson<T>(json['song_artists']),
        thumbnailUrl: json['thumbnail_url'],
        releaseDate: DateTime.parse(json['release_date']),
        isLiked: isLiked,
      );
    } else {
      throw UnsupportedError('Unsupported parse json for type $T');
    }
  }

  Map toJson<T>({bool only = false}) {
    if (T == SupabaseApi) {
      final releaseDateString = releaseDate.toUtc().toIso8601String();
      Map<String, Object> res = {
        'id': id,
        'title': title,
        'artists_names': artistsNames,
        'thumbnail_url': thumbnailUrl,
        'release_date': releaseDateString
      };
      if (!only) {
        res['song_artists'] = artists.map((e) => e.toJson<T>()).toList();
      }
      return res;
    } else {
      throw UnsupportedError('Unsupported convert UserModel to json for type $T');
    }
  }

  static List<SongModel> fromListJson<T>(List list) {
    return list.map((json) => SongModel.fromJson<T>(json)).toList();
  }

  bool setIsLiked(bool newValue, {bool sync = true}) {
    if (sync) {
      unawaited(getIt<ApiKit>().setIsLiked(id, newValue));
    }
    getIt<LikedSongsCubit>().setIsLiked(this, newValue);
    return isLiked = newValue;
  }

  Future<bool> loadIsLiked() async {
    isLiked = await getIt<ApiKit>().getIsLiked(id);
    return isLiked!;
  }

  MediaItem get mediaItem => MediaItem(
    id: id,
    title: title,
    album: 'My album',
    artUri: Uri.parse(thumbnailUrl),
    artist: artistsNames
  );
}
