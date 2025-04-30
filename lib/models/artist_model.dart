import 'package:memecloud/apis/supabase/main.dart';
import 'package:memecloud/apis/zingmp3/endpoints.dart';
import 'package:memecloud/utils/common.dart';

class ArtistModel {
  final String id;
  final String name;
  final String alias;
  final String thumbnailUrl;

  final String? playlistId;
  final String? realname;
  final String? biography;
  final String? shortBiography;
  bool? followed;

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
        thumbnailUrl: json['thumbnailM'] ?? json['thumbnail'],
        playlistId: json['playlistId'],
        realname: json['realname'],
        biography: json['biography'],
        shortBiography: json['sortBiography'],
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

  Map toJson<T>() {
    if (T == SupabaseApi) {
      return {
        'artist': ignoreNullValuesOfMap({
          'id': id,
          'name': name,
          'alias': alias,
          'thumbnail_url': thumbnailUrl,
          'playlist_id': playlistId,
          'realname': realname,
          'bio': biography,
          'short_bio': shortBiography,
        })
      };
    } else {
      throw UnsupportedError(
        'Unsupported convert ArtistModel to json for type $T',
      );
    }
  }

  static List<ArtistModel> fromListJson<T>(List list) {
    return list.map((json) => ArtistModel.fromJson<T>(json)).toList();
  }
}
