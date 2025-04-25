import 'package:memecloud/apis/supabase/songs.dart';
import 'package:memecloud/core/getit.dart';

class SongModel {
  final String id;
  final String title;
  final String artist;
  final String thumbnailUrl;
  final DateTime releaseDate;
  bool? _isLiked;

  SongModel({
    required this.id,
    required this.title,
    required this.artist,
    required this.releaseDate,
    required this.thumbnailUrl,
    bool? isLiked,
  }) : _isLiked = isLiked;

  bool get isLiked => _isLiked!;
  set isLiked(bool newValue) {
    assert(_isLiked != newValue);
    if (_isLiked != null) {
      getIt<SupabaseSongsApi>().setIsLiked(id, newValue);
    }
    _isLiked = newValue;
  }
  Future<bool> loadIsLiked() async {
    if (_isLiked == null) {
      final resp = await getIt<SupabaseSongsApi>().getIsLiked(id);
      resp.fold((l) => throw l, (r) => _isLiked = r);
    }
    return _isLiked!;
  }

  factory SongModel.fromJson(Map<String, dynamic> json) {
    final rawDate = json['release_date'];
    final DateTime releaseDate = (
      rawDate.runtimeType == int
    ) ? (
      DateTime.fromMillisecondsSinceEpoch(1000 * (rawDate as int))
    ) : (
      rawDate.runtimeType == String
    ) ? (
      DateTime.parse(rawDate)
    ) : (
      rawDate as DateTime
    );
    return SongModel(
      id: json['id'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String,
      thumbnailUrl: json['thumbnail_url'] as String,
      releaseDate: releaseDate,
      isLiked: json['is_liked'] as bool?,
    );
  }
}
