class UserModel {
  String id;
  String displayName;
  String email;
  String avatarUrl;

  UserModel._({
    required this.id,
    required this.displayName,
    required this.email,
    this.avatarUrl = '/assets/icons/avatar.jpg',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel._(
      id: json['id'],
      displayName: json['display_name'],
      email: json['email'],
      avatarUrl: json['avatar_url'],
    );
  }

  UserModel copyWith({String? displayName, String? email, String? avatarUrl}) {
    return UserModel._(
      id: id,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
