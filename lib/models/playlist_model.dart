// ignore_for_file: unused_element_parameter

import 'package:memecloud/apis/zingmp3/endpoints.dart';
import 'package:memecloud/models/artist_model.dart';
import 'package:memecloud/models/song_model.dart';

class AnonymousPlaylist {}
const String anonymousId = "AnOnYmOuS";

class PlaylistModel {
  /// `id="AnOnYmOuS"` if it isn't an actual playlist
  final String id;
  final String title;
  final String thumbnailUrl;
  final String? artistsNames;
  final String? description;
  final List<SongModel>? songs;
  final List<ArtistModel>? artists;
  final bool? followed;

  PlaylistModel._({
    this.id = anonymousId,
    required this.title,
    required this.thumbnailUrl,
    this.artistsNames,
    this.description,
    this.songs,
    this.artists,
    this.followed
  });

  static PlaylistModel fromJson<T>(Map<String, dynamic> json, {bool? followed}) {
    if (T == AnonymousPlaylist) {
      return PlaylistModel._(
        title: json['title'],
        artistsNames: json['artists_names'],
        description: json['description'],
        thumbnailUrl: 'https://images.pexels.com/photos/104827/cat-pet-animal-domestic-104827.jpeg?cs=srgb&dl=pexels-pixabay-104827.jpg&fm=jpg',
        songs: json.containsKey('songs') ? SongModel.fromListJson<T>(json['songs']) : null
      );
    } else if (T == ZingMp3Api) {
      return PlaylistModel._(
        id: json['encodeId'],
        title: json['title'],
        artistsNames: json['artistsNames'],
        thumbnailUrl: json['thumbnailM'] ?? json['thumbnail'],
        description: json['sortDescription'] ?? json['description'],
        songs: json.containsKey('song') ? SongModel.fromListJson<T>(json['song']['items']) : null,
        artists: json.containsKey('artists') ? ArtistModel.fromListJson<T>(json['artists']) : null
      );
    } else {
      throw UnsupportedError('Unsupported parse json for type $T');
    }
  }

  static List<PlaylistModel> fromListJson<T>(List list) {
    return list.map((json) => PlaylistModel.fromJson<T>(json)).toList();
  }
}