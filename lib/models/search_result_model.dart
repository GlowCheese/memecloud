import 'package:memecloud/apis/zingmp3.dart';
import 'package:memecloud/models/artist_model.dart';
import 'package:memecloud/models/playlist_model.dart';
import 'package:memecloud/models/song_model.dart';

class SearchResultModel {
  /// Either `SongModel`, `ArtistModel`, `PlaylistModel` or `null`.
  Object? bestMatch;
  final List<SongModel> songs;
  final List<ArtistModel> artists;
  final List<PlaylistModel> playlists;

  SearchResultModel._({
    this.bestMatch,
    required this.songs,
    required this.artists,
    required this.playlists,
  });

  static SearchResultModel fromJson(Map json) {
    late final Object? bestMatch;
    if (!json.containsKey('top')) {
      bestMatch = null;
    } else {
      switch (json['top']['objectType']) {
        case 'artist':
          bestMatch = ArtistModel.fromJson<ZingMp3Api>(json['top']);
          break;
        case 'song':
          bestMatch = SongModel.fromJson<ZingMp3Api>(json['top']);
          break;
        case 'playlist':
          bestMatch = PlaylistModel.fromJson<ZingMp3Api>(json['top']);
          break;
        case 'video':
          bestMatch = null;
          break;
        default:
          throw UnsupportedError(
            "Search parse failed to parse json['top'] = '${json['top']}'.",
          );
      }
    }

    late final List<ArtistModel>? artists;
    if (!json.containsKey('artists')) {
      artists = [];
    } else {
      artists = ArtistModel.fromListJson<ZingMp3Api>(json['artists']);
    }

    late final List<SongModel>? songs;
    if (!json.containsKey('songs')) {
      songs = [];
    } else {
      songs = SongModel.fromListJson<ZingMp3Api>(json['songs']);
    }

    late final List<PlaylistModel>? playlists;
    if (!json.containsKey('playlists')) {
      playlists = [];
    } else {
      playlists = PlaylistModel.fromListJson<ZingMp3Api>(json['playlists']);
    }

    return SearchResultModel._(
      bestMatch: bestMatch,
      songs: songs,
      artists: artists,
      playlists: playlists,
    );
  }
}
