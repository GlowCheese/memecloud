enum IssueType {
  bug(text: 'Lỗi hệ thống'),
  music(text: 'Vấn đề về âm nhạc'),
  uiux(text: 'Trải nghiệm người dùng'),
  contribute(text: 'Đóng góp'),
  etc(text: 'Khác');

  final String text;
  const IssueType({required this.text});

  factory IssueType.fromText(String text) {
    for (IssueType value in IssueType.values) {
      if (value.text == text) return value;
    }
    throw Exception('Invalid type of IssueType');
  }
}

class IssueModel {
  final String userId;
  final IssueType type;
  final String description;
  final DateTime createdAt;

  IssueModel({
    required this.userId,
    required this.type,
    required this.description,
    required this.createdAt,
  });

  factory IssueModel.fromJson(Map<String, dynamic> json) {
    return IssueModel(
      userId: json['user_id'] ?? '',
      type: json['type'] ?? '',
      description: json['description'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'type': type,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
