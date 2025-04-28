// ignore_for_file: unused_element_parameter

import 'package:memecloud/models/artist_model.dart';
import 'package:memecloud/models/song_model.dart';

class AnonymousPlaylist {}
const String anonymousId = "AnOnYmOuS";

class PlaylistModel {
  /// `id="AnOnYmOuS"` if it isn't an actual playlist
  final String id;
  final String title;
  final String? artistsNames;
  final String? thumbnailUrl;
  final String? description;
  final String? shortDescription;
  final List<SongModel>? songs;
  final List<ArtistModel>? artists;
  final bool? followed;

  PlaylistModel._({
    this.id = anonymousId,
    required this.title,
    this.artistsNames,
    this.thumbnailUrl,
    this.description,
    this.shortDescription,
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
        songs: json.containsKey('songs') ? SongModel.fromListJson<T>(json['songs']) : null
      );
    } else {
      throw UnsupportedError('Unsupported parse json for type $T');
    }
  }
}