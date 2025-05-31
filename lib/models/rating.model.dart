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
      musicRating: (json['music'] ?? 0).toDouble(),
      uiRating: (json['ui'] ?? 0).toDouble(),
      uxRating: (json['ux'] ?? 0).toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'music': musicRating,
      'ui': uiRating,
      'ux': uxRating,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
