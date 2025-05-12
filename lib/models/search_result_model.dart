import 'package:memecloud/apis/zingmp3/endpoints.dart';
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

  static Future<SearchResultModel> fromJson(Map json) async {
    late final Object? bestMatch;
    if (!json.containsKey('top')) {
      bestMatch = null;
    } else {
      switch (json['top']['objectType']) {
        case 'artist':
          bestMatch = await ArtistModel.fromJson<ZingMp3Api>(json['top']);
          break;
        case 'song':
          bestMatch = await SongModel.fromJson<ZingMp3Api>(json['top']);
          break;
        case 'playlist':
          bestMatch = await PlaylistModel.fromJson<ZingMp3Api>(json['top']);
          break;
        case 'hub':
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
      artists = await ArtistModel.fromListJson<ZingMp3Api>(json['artists']);
    }

    late final List<SongModel>? songs;
    if (!json.containsKey('songs')) {
      songs = [];
    } else {
      songs = await SongModel.fromListJson<ZingMp3Api>(json['songs']);
    }

    late final List<PlaylistModel>? playlists;
    if (!json.containsKey('playlists')) {
      playlists = [];
    } else {
      playlists = await PlaylistModel.fromListJson<ZingMp3Api>(json['playlists']);
    }

    return SearchResultModel._(
      bestMatch: bestMatch,
      songs: songs,
      artists: artists,
      playlists: playlists,
    );
  }
}
