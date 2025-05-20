import 'package:memecloud/utils/common.dart';
import 'package:memecloud/apis/supabase/main.dart';
import 'package:memecloud/models/music_model.dart';
import 'package:memecloud/models/section_model.dart';
import 'package:memecloud/apis/zingmp3/endpoints.dart';

class ArtistModel extends MusicModel {
  final String id;
  final String name;
  final String alias;
  final String thumbnailUrl;

  final String? playlistId;
  final String? realname;
  final String? biography;
  final String? shortBiography;
  final List<SectionModel>? sections;

  ArtistModel._({
    required this.id,
    required this.name,
    required this.alias,
    required this.thumbnailUrl,
    this.playlistId,
    this.realname,
    this.biography,
    this.shortBiography,
    this.sections,
  });

  static ArtistModel fromJson<T>(Map<String, dynamic> json) {
    if (T == ZingMp3Api) {
      List<SectionModel>? sections;
      if (json.containsKey('sections')) {
        sections = SectionModel.fromListJson<T>(List.castFrom<dynamic, Map<String, dynamic>>(json['sections']));
      }

      return ArtistModel._(
        id: json['id'],
        name: json['name'],
        alias: json['alias'],
        thumbnailUrl: json['thumbnailM'] ?? json['thumbnail'],
        playlistId: json['playlistId'],
        realname: json['realname'],
        biography: json['biography'],
        shortBiography: json['sortBiography'],
        sections: sections,
      );
    } else if (T == SupabaseApi) {
      final art = json['artist'];
      return ArtistModel._(
        id: art['id'],
        name: art['name'],
        alias: art['alias'],
        thumbnailUrl: art['thumbnail_url'],
        playlistId: art['playlist_id'],
      );
    } else {
      throw UnsupportedError('Unsupported parse json for type $T');
    }
  }

  @override
  Map<String, dynamic> toJson() {
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
        'sections': sections?.map((e) => e.toJson()).toList(),
      }),
    };
  }

  static List<ArtistModel> fromListJson<T>(List list) {
    return list.map((json) => ArtistModel.fromJson<T>(json)).toList();
  }
}
