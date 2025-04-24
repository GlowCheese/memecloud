import 'package:memecloud/apis/supabase/songs.dart';
import 'package:memecloud/core/getit.dart';

class SongModel {
  final String id;
  final String title;
  final String artist;
  final String url;
  bool _isLiked;
  final String thumbnailUrl;

  final int? releaseDate;

  SongModel({
    required this.id,
    required this.title,
    required this.artist,
    required this.url,
    required bool isLiked,
    required this.thumbnailUrl,
    this.releaseDate,
  }) : _isLiked = isLiked;

  bool get isLiked => _isLiked;
  set isLiked(bool newValue) {
    assert(_isLiked != newValue);
    _isLiked = newValue;
    getIt<SupabaseSongsApi>().setLike(id, newValue);
  }

  factory SongModel.fromJson(Map<String, dynamic> json) {
    return SongModel(
      id: json['id'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String,
      url: json['url'] as String,
      isLiked: json['is_liked'],
      thumbnailUrl: json['thumbnail_url'] as String,
    );
  }
}
