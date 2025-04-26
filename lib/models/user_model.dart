class UserModel {
  String? id;
  String? fullName;
  String? email;
  String? avatarUrl;

  UserModel({this.id, this.fullName, this.email, this.avatarUrl});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString(),
      fullName: json['display_name']?.toString(),
      email: json['email']?.toString(),
      avatarUrl: json['avatarUrl']?.toString(),
    );
  }
}
