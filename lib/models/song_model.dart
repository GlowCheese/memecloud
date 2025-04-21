class SongModel {
  final String id;
  final String title;
  final String artist;
  final String coverUrl;
  final String url;

  SongModel({
    required this.id,
    required this.title,
    required this.artist,
    required this.coverUrl,
    required this.url,
  });

  factory SongModel.fromJson(Map<String, dynamic> json) {
    return SongModel(
      id: json['id'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String,
      coverUrl: json['cover_url'] as String,
      url: json['url'] as String,
    );
  }
}
