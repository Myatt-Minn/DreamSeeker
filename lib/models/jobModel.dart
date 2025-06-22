class JobModel {
  final int? id;
  final String title;
  final String company;
  final String location;
  final String description;
  final String jobType; // e.g., Full-time, Part-time, Remote
  final String salary; // e.g., $60k - $80k/year
  final List<String> requirements;
  final DateTime postedAt;
  final bool featured; // <-- Added field

  JobModel({
    this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.description,
    required this.jobType,
    required this.salary,
    required this.requirements,
    required this.postedAt,
    required this.featured, // <-- Added field
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      title: json['title'] as String? ?? '',
      company: json['company'] as String? ?? '',
      location: json['location'] as String? ?? '',
      description: json['description'] as String? ?? '',
      jobType: json['job_type'] as String? ?? '',
      salary: json['salary'] as String? ?? '',
      requirements: List<String>.from(json['requirements'] ?? []),
      postedAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      featured: json['featured'] as bool? ?? false, // <-- Added field
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'company': company,
      'location': location,
      'description': description,
      'job_type': jobType,
      'salary': salary,
      'requirements': requirements,
      'created_at': postedAt.toIso8601String(),
      'featured': featured, // <-- Added field
    };
  }
}
