import 'package:memecloud/apis/zingmp3/endpoints.dart';
import 'package:memecloud/models/artist_model.dart';
import 'package:memecloud/models/music_model.dart';
import 'package:memecloud/models/playlist_model.dart';
import 'package:memecloud/models/song_model.dart';

abstract class SectionModel {
  final String title;
  final List<MusicModel> items;

  SectionModel({required this.title, required this.items});

  static Future<SectionModel?> fromJson<T>(Map<String, dynamic> json) async {
    if (T == ZingMp3Api) {
      if (json['sectionType'] == 'song') {
        return await SongSection.fromJson<T>(json);
      }
      // TODO: uncomment this whenever you need it!
      // if (json['sectionType'] == 'artist') {
      //   return await ArtistSection.fromJson<T>(json);
      // }
      if (json['sectionType'] == 'playlist') {
        return await PlaylistSection.fromJson<T>(json);
      }
      return null;
    }
    throw UnsupportedError('Cannot parse SectionModel for type $T');
  }

  static Future<List<SectionModel>> fromListJson<T>(
    List<Map<String, dynamic>> list,
  ) async {
    return (await Future.wait(
      list.map(SectionModel.fromJson<T>)
    )).whereType<SectionModel>().toList();
  }

  Map<String, dynamic> toJson() {
    String? sectionType;
    if (this is SongSection) sectionType = 'song';
    if (this is ArtistSection) sectionType = 'artist';
    if (this is PlaylistSection) sectionType = 'playlist';

    return {
      'title': title,
      'section_type': sectionType,
      'items': items.map((e) => e.toJson()).toList(),
    };
  }
}

class SongSection extends SectionModel {
  SongSection({required super.title, required List<SongModel> super.items});

  static Future<SongSection> fromJson<T>(Map<String, dynamic> json) async {
    if (T == ZingMp3Api) {
      return SongSection(
        title: json['title'],
        items: await SongModel.fromListJson<T>(json['items']),
      );
    }
    throw UnsupportedError('Cannot parse SongSection for type $T');
  }
}

class ArtistSection extends SectionModel {
  ArtistSection({required super.title, required List<ArtistModel> super.items});

  static Future<ArtistSection> fromJson<T>(Map<String, dynamic> json) async {
    if (T == ZingMp3Api) {
      return ArtistSection(
        title: json['title'],
        items: await ArtistModel.fromListJson<T>(json['items']),
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

  static Future<PlaylistSection> fromJson<T>(Map<String, dynamic> json) async {
    if (T == ZingMp3Api) {
      return PlaylistSection(
        title: json['title'],
        items: await PlaylistModel.fromListJson<T>(json['items']),
      );
    }
    throw UnsupportedError('Cannot parse PlaylistSection for type $T');
  }
}
