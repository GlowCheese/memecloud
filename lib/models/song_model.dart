class SongModel {
  final String id;
  final String title;
  final String artist;
  final String url;

  final int? releaseDate;
  final String? thumbnailUrl;

  SongModel({
    required this.id,
    required this.title,
    required this.artist,
    required this.url,

    this.releaseDate,
    this.thumbnailUrl,
  });

  factory SongModel.fromJson(Map<String, dynamic> json) {
    return SongModel(
      id: json['id'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String,
      url: json['url'] as String,
      thumbnailUrl: json['thumbnail_url'] as String?,
    );
  }
}
