class RatingModel {
  final String userId;
  final double musicRating;
  final double uiRating;
  final double uxRating;
  final DateTime createdAt;

  RatingModel({
    required this.userId,
    required this.musicRating,
    required this.uiRating,
    required this.uxRating,
    required this.createdAt,
  });

  factory RatingModel.fromJson(Map<String, dynamic> json) {
    return RatingModel(
      userId: json['user_id'],
      musicRating: (json['musicRating'] ?? 0).toDouble(),
      uiRating: (json['uiRating'] ?? 0).toDouble(),
      uxRating: (json['uxRating'] ?? 0).toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'musicRating': musicRating,
      'uiRating': uiRating,
      'uxRating': uxRating,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
