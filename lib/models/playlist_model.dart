// ignore_for_file: unused_element_parameter

import 'package:memecloud/core/getit.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:memecloud/models/user_model.dart';
import 'package:memecloud/utils/common.dart';
import 'package:memecloud/models/song_model.dart';
import 'package:memecloud/apis/supabase/main.dart';
import 'package:memecloud/models/music_model.dart';
import 'package:memecloud/models/artist_model.dart';
import 'package:memecloud/apis/zingmp3/endpoints.dart';

enum PlaylistType { zing, likedSongs, downloaded, user }

class PlaylistModel extends MusicModel {
  final String id;
  final String title;
  final PlaylistType type;
  final String thumbnailUrl;
  final String? artistsNames;
  final String? description;
  final List<SongModel>? songs;
  final List<ArtistModel>? artists;

  PlaylistModel._({
    required this.id,
    required this.title,
    required this.type,
    required this.thumbnailUrl,
    this.artistsNames,
    this.description,
    this.songs,
    this.artists,
  });

  static PlaylistModel fromJson<T>(Map<String, dynamic> json) {
    if (T == ZingMp3Api) {
      return PlaylistModel._(
        id: json['encodeId'],
        title: json['title'],
        type: PlaylistType.zing,
        artistsNames: json['artistsNames'],
        thumbnailUrl:
            json['thumbnailM'] ?? json['thumbnail'] ?? json['thumbnailUrl'],
        description: json['sortDescription'] ?? json['description'] ?? 'mô tả',
        songs:
            json.containsKey('song')
                ? SongModel.fromListJson<T>(json['song']['items'])
                : null,
        artists:
            json.containsKey('artists')
                ? ArtistModel.fromListJson<T>(json['artists'])
                : null,
      );
    } else if (T == SupabaseApi) {
      return PlaylistModel._(
        id: json['id'],
        title: json['title'],
        type: PlaylistType.zing,
        artistsNames: json['artists_names'],
        thumbnailUrl: json['thumbnail_url'],
        description: json['description'],
        songs:
            (json['playlist_songs'] as List?)
                ?.map((e) => SongModel.fromJson<SupabaseApi>(e['song']))
                .toList(),
        artists:
            (json['playlist_artists'] as List?)
                ?.map((e) => ArtistModel.fromJson<SupabaseApi>(e))
                .toList(),
      );
    } else {
      return PlaylistModel._(
        id: json['id'] ?? 'noid',
        title: json['title'],
        type: PlaylistType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => PlaylistType.zing,
        ),
        artistsNames: json['artistsNames'],
        description: json['description'],
        thumbnailUrl: json['thumbnailUrl'],
        songs: json.containsKey('songs') ? json['songs'] : null,
      );
    }
  }

  static List<PlaylistModel> fromListJson<T>(List list) {
    return list.map((json) => PlaylistModel.fromJson<T>(json)).toList();
  }

  static String userName() => getIt<ApiKit>().myProfile().displayName;

  factory PlaylistModel.likedPlaylist() {
    return PlaylistModel.fromJson({
      'title': 'Bài hát đã thích',
      'type': PlaylistType.likedSongs.name,
      'artistsNames': userName(),
      'thumbnailUrl': 'assets/icons/liked_songs.jpeg',
      'songs': getIt<ApiKit>().getLikedSongs(),
    });
  }

  factory PlaylistModel.downloadedPlaylist() {
    return PlaylistModel.fromJson({
      'title': 'Bài hát tải xuống',
      'type': PlaylistType.downloaded.name,
      'artistsNames': userName(),
      'thumbnailUrl': 'assets/icons/downloaded_songs.webp',
      'songs': getIt<ApiKit>().getDownloadedSongs(),
    });
  }

  factory PlaylistModel.userPlaylist({
    required UserModel user,
    required String id,
    required String title,
    String? description,
    String thumbnailUrl = 'assets/icons/user_playlist.png',
    List<SongModel>? songs,
  }) {
    return PlaylistModel._(
      id: id,
      title: title,
      type: PlaylistType.user,
      thumbnailUrl: thumbnailUrl,
      artistsNames: user.displayName,
      description: description,
      songs: songs ?? [],
    );
  }

  @override
  Map<String, dynamic> toJson({bool only = false}) {
    return ignoreNullValuesOfMap({
      'id': id,
      'title': title,
      'type': type.name,
      'thumbnail_url': thumbnailUrl,
      'artists_names': artistsNames,
      'description': description,
      if (only == false)
        'playlist_songs': songs?.map((e) => {'song': e.toJson()}).toList(),
      if (only == false)
        'playlist_artists': artists?.map((e) => e.toJson()).toList(),
    });
  }

  bool get isFollowed {
    return getIt<ApiKit>().isPlaylistFollowed(id);
  }

  set isFollowed(bool isFollowed) {
    getIt<ApiKit>().setIsPlaylistFollowed(this, isFollowed);
  }
}
