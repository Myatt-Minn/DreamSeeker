class UserModel {
  final String id;

  final String email;
  final String password;
  final String role;

  UserModel({
    required this.id,
    required this.email,
    required this.password,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['user_id'],
      email: json['email'],
      password: json['password'],
      role: json['role'] ?? 'seeker', // Default to 'seeker'
    );
  }

  Map<String, dynamic> toJson() {
    return {'user_id': id, 'email': email, 'password': password, 'role': role};
  }
}
