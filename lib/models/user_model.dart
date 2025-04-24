class UserModel {
  String? id;
  String? fullName;
  String? email;
  String? avatarUrl;

  UserModel({this.id, this.fullName, this.email, this.avatarUrl});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      fullName: json['display_name'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatarUrl'] as String,
    );
  }
}
