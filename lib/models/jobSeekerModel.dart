class JobSeekerModel {
  final int? id; // <-- Added field
  final String userId;
  final String email;
  final String password;
  final String profile_pic; // local path or URL
  final String full_name;
  final String experience;
  final String education;
  final String position;
  final List<String> skills;

  JobSeekerModel({
    this.id, // <-- Added field
    required this.userId,
    required this.email,
    required this.password,
    required this.profile_pic,
    required this.full_name,
    required this.experience,
    required this.education,
    required this.position,
    required this.skills,
  });

  factory JobSeekerModel.fromJson(Map<String, dynamic> json) {
    return JobSeekerModel(
      userId: json['user_id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      password: json['password'] as String? ?? '',
      profile_pic: json['profile_pic'] as String? ?? '',
      full_name: json['full_name'] as String? ?? '',
      experience: json['experience'] as String? ?? '',
      education: json['education'] as String? ?? '',
      position: json['position'] as String? ?? '',
      skills: List<String>.from(json['skills'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id, // <-- Added field
      'user_id': userId,
      'email': email,
      'password': password,
      'profile_pic': profile_pic,
      'full_name': full_name,
      'experience': experience,
      'education': education,
      'position': position,
      'skills': skills,
    };
  }
}
