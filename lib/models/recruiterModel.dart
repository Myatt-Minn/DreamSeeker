class RecruiterModel {
  final String id;
  final String userId;
  final String email;
  final String password;
  final String profilePic; // URL or local path
  final String fullName;
  final String companyName;
  final String companyWebsite;
  final String companyLocation;
  final String companyDescription;
  final DateTime createdAt;

  RecruiterModel({
    required this.id,
    required this.userId,
    required this.email,
    required this.password,
    required this.profilePic,
    required this.fullName,
    required this.companyName,
    required this.companyWebsite,
    required this.companyLocation,
    required this.companyDescription,
    required this.createdAt,
  });

  factory RecruiterModel.fromJson(Map<String, dynamic> json) {
    return RecruiterModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      profilePic: json['profile_pic'] as String,
      fullName: json['full_name'] as String,
      companyName: json['company_name'] as String,
      companyWebsite: json['company_website'] as String,
      companyLocation: json['company_location'] as String,
      companyDescription: json['company_description'] as String,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'email': email,
      'password': password,
      'profile_pic': profilePic,
      'full_name': fullName,
      'company_name': companyName,
      'company_website': companyWebsite,
      'company_location': companyLocation,
      'company_description': companyDescription,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
