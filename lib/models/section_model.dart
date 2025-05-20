import 'package:memecloud/apis/zingmp3/endpoints.dart';
import 'package:memecloud/models/artist_model.dart';
import 'package:memecloud/models/music_model.dart';
import 'package:memecloud/models/playlist_model.dart';
import 'package:memecloud/models/song_model.dart';

abstract class SectionModel {
  final String title;
  final List<MusicModel> items;

  SectionModel({required this.title, required this.items});

  static SectionModel? fromJson<T>(Map<String, dynamic> json) {
    if (T == ZingMp3Api) {
      if (json['sectionType'] == 'song') {
        return SongSection.fromJson<T>(json);
      }
      // TODO: uncomment this whenever you need it!
      // if (json['sectionType'] == 'artist') {
      //   return ArtistSection.fromJson<T>(json);
      // }
      if (json['sectionType'] == 'playlist') {
        return PlaylistSection.fromJson<T>(json);
      }
      return null;
    }
    throw UnsupportedError('Cannot parse SectionModel for type $T');
  }

  static List<SectionModel> fromListJson<T>(List<Map<String, dynamic>> list) {
    return list
        .map(SectionModel.fromJson<T>)
        .whereType<SectionModel>()
        .toList();
  }

  Map<String, dynamic> toJson({bool only = false}) {
    String? sectionType;
    if (this is SongSection) sectionType = 'song';
    if (this is ArtistSection) sectionType = 'artist';
    if (this is PlaylistSection) sectionType = 'playlist';

    return {
      'title': title,
      'section_type': sectionType,
      'items': items.map((e) => e.toJson(only: only)).toList(),
    };
  }
}

class SongSection extends SectionModel {
  SongSection({required super.title, required List<SongModel> super.items});

  static SongSection fromJson<T>(Map<String, dynamic> json) {
    if (T == ZingMp3Api) {
      return SongSection(
        title: json['title'],
        items: SongModel.fromListJson<T>(json['items']),
      );
    }
    throw UnsupportedError('Cannot parse SongSection for type $T');
  }
}

class ArtistSection extends SectionModel {
  ArtistSection({required super.title, required List<ArtistModel> super.items});

  static ArtistSection fromJson<T>(Map<String, dynamic> json) {
    if (T == ZingMp3Api) {
      return ArtistSection(
        title: json['title'],
        items: ArtistModel.fromListJson<T>(json['items']),
      );
    }
    throw UnsupportedError('Cannot parse ArtistSection for type $T');
  }
}

class PlaylistSection extends SectionModel {
  PlaylistSection({
    required super.title,
    required List<PlaylistModel> super.items,
  });

  static PlaylistSection fromJson<T>(Map<String, dynamic> json) {
    if (T == ZingMp3Api) {
      return PlaylistSection(
        title: json['title'],
        items: PlaylistModel.fromListJson<T>(json['items']),
      );
    }
    throw UnsupportedError('Cannot parse PlaylistSection for type $T');
  }
}
