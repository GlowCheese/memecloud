import 'package:memecloud/blocs/liked_songs/liked_songs_stream.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:memecloud/apis/supabase/main.dart';
import 'package:memecloud/models/music_model.dart';
import 'package:memecloud/models/artist_model.dart';
import 'package:memecloud/apis/zingmp3/endpoints.dart';
import 'package:just_audio_background/just_audio_background.dart';

class SongModel extends MusicModel {
  final String id;
  final String title;
  final Duration duration;
  final String artistsNames;
  final String thumbnailUrl;
  final DateTime releaseDate;
  final List<ArtistModel> artists;

  // Private constructor
  SongModel._({
    required this.id,
    required this.title,
    required this.duration,
    required this.artistsNames,
    required this.artists,
    required this.releaseDate,
    required this.thumbnailUrl,
  });

  static SongModel fromJson<T>(Map<String, dynamic> json) {
    if (T == ZingMp3Api) {
      return SongModel._(
        id: json['encodeId'],
        title: json['title'],
        duration: Duration(seconds: json['duration'] as int),
        artistsNames: json['artistsNames'],
        thumbnailUrl: json['thumbnailM'] ?? json['thumbnail'],
        releaseDate: DateTime.fromMillisecondsSinceEpoch(
          json['releaseDate'] * 1000,
        ),
        artists:
            !json.containsKey('artists')
                ? []
                : ArtistModel.fromListJson<T>(json['artists']),
      );
    } else if (T == SupabaseApi) {
      return SongModel._(
        id: json['id'],
        title: json['title'],
        duration: Duration(seconds: json['duration'] as int),
        artistsNames: json['artists_names'],
        artists: ArtistModel.fromListJson<T>(json['song_artists']),
        thumbnailUrl: json['thumbnail_url'],
        releaseDate: DateTime.parse(json['release_date']),
      );
    } else {
      throw UnsupportedError('Unsupported parse json for type $T');
    }
  }

  @override
  Map<String, dynamic> toJson({bool only = false}) {
    final releaseDateString = releaseDate.toUtc().toIso8601String();
    Map<String, Object> res = {
      'id': id,
      'title': title,
      'duration': duration.inSeconds,
      'artists_names': artistsNames,
      'thumbnail_url': thumbnailUrl,
      'release_date': releaseDateString,
    };
    if (only == false) {
      res['song_artists'] = artists.map((e) => e.toJson()).toList();
    }
    return res;
  }

  static List<SongModel> fromListJson<T>(List list) {
    final tmp = list.map((json) => SongModel.fromJson<T>(json));

    try {
      final songIds = getIt<ApiKit>().filterPlayableSongs(
        tmp.map((e) => e.id).toList(),
      );
      return tmp.where((e) => songIds.contains(e.id)).toList();
    } catch (_) {
      return tmp.toList();
    }
  }

  bool get isLiked {
    return getIt<ApiKit>().isSongLiked(id);
  }
  set isLiked(bool isLiked) {
    getIt<ApiKit>().setIsSongLiked(this, isLiked);
    getIt<LikedSongsStream>().setIsLiked(this, isLiked);
  }

  MediaItem get mediaItem => MediaItem(
    id: id,
    title: title,
    album: 'My album',
    duration: duration,
    artUri: Uri.parse(thumbnailUrl),
    artist: artistsNames,
  );
}
