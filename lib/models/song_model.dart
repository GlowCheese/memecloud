import 'package:memecloud/apis/apikit.dart';
import 'package:memecloud/apis/supabase/main.dart';
import 'package:memecloud/apis/zingmp3.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/models/artist_model.dart';

class SongModel {
  final String id;
  final String title;
  final String artistsNames;
  final String thumbnailUrl;
  final DateTime releaseDate;
  final List<ArtistModel> artists;
  bool? _isLiked;

  // Private constructor
  SongModel._({
    required this.id,
    required this.title,
    required this.artistsNames,
    required this.artists,
    required this.releaseDate,
    required this.thumbnailUrl,
    bool? isLiked,
  }) : _isLiked = isLiked;

  static SongModel fromJson<T>(Map<String, dynamic> json, {bool? isLiked}) {
    if (T == ZingMp3Api) {
      return SongModel._(
        id: json['encodeId'],
        title: json['title'],
        artistsNames: json['artistsNames'],
        thumbnailUrl: json['thumbnailM'],
        releaseDate: DateTime.fromMillisecondsSinceEpoch(
          json['releaseDate'] * 1000,
        ),
        artists: ArtistModel.fromListJson<T>(json['artists']),
        isLiked: isLiked,
      );
    } else if (T == SupabaseApi) {
      return SongModel._(
        id: json['id'],
        title: json['title'],
        artistsNames: json['artists_names'],
        artists: ArtistModel.fromListJson<T>(json['song_artists']),
        thumbnailUrl: json['thumbnail_url'],
        releaseDate: DateTime.parse(json['release_date']),
        isLiked: isLiked,
      );
    } else {
      throw UnsupportedError('Unsupported parse json for type $T');
    }
  }

  bool get isLiked => _isLiked!;
  set isLiked(bool newValue) {
    assert(_isLiked! != newValue);
    // TODO: sync this even if we're offline!
    getIt<ApiKit>().setIsLiked(id, newValue);
    _isLiked = newValue;
  }

  Future<bool> loadIsLiked() async {
    final resp = await getIt<ApiKit>().getIsLiked(id);
    resp.fold((l) => throw l, (r) => _isLiked = r);
    return _isLiked!;
  }
}
