import 'package:memecloud/apis/supabase/main.dart';
import 'package:memecloud/apis/zingmp3.dart';

class ArtistModel {
  final String id;
  final String name;
  final String alias;
  final String thumbnailUrl;

  final String? playlistId;
  final String? realname;
  final String? biography;
  final String? shortBiography;
  final bool? followed;

  ArtistModel._({
    required this.id,
    required this.name,
    required this.alias,
    required this.thumbnailUrl,
    this.playlistId,
    this.realname,
    this.biography,
    this.shortBiography,
    this.followed,
  });

  static ArtistModel fromJson<T>(Map<String, dynamic> json, {bool? followed}) {
    if (T == ZingMp3Api) {
      return ArtistModel._(
        id: json['id'],
        name: json['name'],
        alias: json['alias'],
        thumbnailUrl: json['thumbnailM'],
        playlistId: json['playlistId'],
        realname: json['realname'],
        biography: json['biography'],
        shortBiography: json['shortBiography'],
        followed: followed,
      );
    } else if (T == SupabaseApi) {
      final art = json['artist'];
      return ArtistModel._(
        id: art['id'],
        name: art['name'],
        alias: art['alias'],
        thumbnailUrl: art['thumbnail_url'],
        playlistId: art['playlist_id'],
        realname: art['realname'],
        biography: art['bio'],
        shortBiography: art['short_bio'],
        followed: followed,
      );
    } else {
      throw UnsupportedError('Unsupported parse json for type $T');
    }
  }

  static List<ArtistModel> fromListJson<T>(List list) {
    return list.map((json) => ArtistModel.fromJson<T>(json)).toList();
  }
}
