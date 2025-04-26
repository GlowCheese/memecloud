class UserModel {
  String id;
  String displayName;
  String email;
  String? avatarUrl;

  UserModel._({
    required this.id,
    required this.displayName,
    required this.email,
    this.avatarUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel._(
      id: json['id'],
      displayName: json['display_name'],
      email: json['email'],
      avatarUrl: json['avatar_url'],
    );
  }
}
