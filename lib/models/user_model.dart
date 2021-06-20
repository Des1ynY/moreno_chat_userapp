class UserModel {
  String email, name, avatar;

  UserModel({required this.email, required this.name, required this.avatar});

  factory UserModel.fromJson(Map<String, dynamic>? json) {
    return UserModel(
      email: json?['email'],
      name: json?['name'],
      avatar: json?['avatar'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'avatar': avatar,
    };
  }
}
