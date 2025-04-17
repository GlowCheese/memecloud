class SongDto {
  final String id;
  final String title;
  final String artist;
  final String coverUrl;
  final String url;

  SongDto({
    required this.id,
    required this.title,
    required this.artist,
    required this.coverUrl,
    required this.url,
  });

  factory SongDto.fromJson(Map<String, dynamic> json) {
    return SongDto(
      id: json['id'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String,
      coverUrl: json['cover_url'] as String,
      url: json['url'] as String,
    );
  }
}
