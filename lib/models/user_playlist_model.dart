class UserPlaylistModel {
  final String id;
  final String playlistName;
  final String description;
  final String userId;
  final String createdAt;
  final String updatedAt;
  final String coverImage;

  UserPlaylistModel({
    required this.id,
    required this.playlistName,
    required this.description,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    required this.coverImage,
  });

  factory UserPlaylistModel.fromJson(Map<String, dynamic> json) {
    return UserPlaylistModel(
      id: json['id'],
      playlistName: json['playlist_name'],
      description: json['description'],
      userId: json['user_id'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      coverImage: json['cover_image'],

    );
  }

  Map<String, dynamic> toJson() {
    return {
      'playlist_name': playlistName,
      'description': description,
      'user_id': userId,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'cover_image': coverImage,
    };
  }
}
