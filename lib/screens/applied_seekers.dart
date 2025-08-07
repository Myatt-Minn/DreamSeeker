import 'package:dream_seeker/models/jobModel.dart';
import 'package:dream_seeker/models/jobSeekerModel.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ApplicationData {
  final JobModel job;
  final JobSeekerModel seeker;
  final String cvUrl;
  final int applicationId;

  ApplicationData({
    required this.job,
    required this.seeker,
    required this.cvUrl,
    required this.applicationId,
  });
}

class AppliedSeekers extends StatefulWidget {
  const AppliedSeekers({super.key});

  @override
  State<AppliedSeekers> createState() => _AppliedSeekersState();
}

class _AppliedSeekersState extends State<AppliedSeekers> {
  List<ApplicationData> applications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchApplications();
  }

  Future<void> fetchApplications() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      // Fetch applications for current recruiter's jobs
      final applicationsResponse = await Supabase.instance.client
          .from('applications')
          .select('id, seeker_id, job_id, cv, recruiter_id')
          .eq('recruiter_id', user.id);

      if (applicationsResponse.isEmpty) {
        setState(() {
          applications = [];
          isLoading = false;
        });
        return;
      }

      List<ApplicationData> loadedApplications = [];

      for (var application in applicationsResponse) {
        try {
          // Fetch job details
          final jobResponse = await Supabase.instance.client
              .from('jobs')
              .select()
              .eq('id', application['job_id'])
              .single();

          // Fetch seeker details
          final seekerResponse = await Supabase.instance.client
              .from('seekers')
              .select()
              .eq('user_id', application['seeker_id'])
              .single();

          final job = JobModel.fromJson(jobResponse);
          final seeker = JobSeekerModel.fromJson(seekerResponse);

          loadedApplications.add(
            ApplicationData(
              job: job,
              seeker: seeker,
              cvUrl: application['cv'] ?? '',
              applicationId: application['id'],
            ),
          );
        } catch (e) {
          print('Error loading application data: $e');
          continue;
        }
      }

      setState(() {
        applications = loadedApplications;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        applications = [];
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load applications: $e')),
      );
    }
  }

  Future<void> _openCV(String cvUrl) async {
    if (cvUrl.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No CV available')));
      return;
    }

    try {
      final Uri url = Uri.parse(cvUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $cvUrl';
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to open CV: $e')));
    }
  }

  final List<Color> avatarColors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.red,
    Colors.teal,
    Colors.amber,
    Colors.cyan,
    Colors.deepOrange,
    Colors.indigo,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: const SizedBox(),
        title: const Text(
          'Job Applications',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : applications.isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No applications yet',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Applications will appear here when job seekers apply to your jobs.',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: applications.length,
                itemBuilder: (context, index) {
                  final applicationData = applications[index];
                  final color = avatarColors[index % avatarColors.length];
                  return _buildApplicationCard(applicationData, color: color);
                },
              ),
      ),
    );
  }

  Widget _buildApplicationCard(
    ApplicationData applicationData, {
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Job Info Section
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: color,
                child: const Icon(Icons.work, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      applicationData.job.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      applicationData.job.company,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),

          // Applicant Info Section
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: applicationData.seeker.profile_pic.isNotEmpty
                    ? NetworkImage(applicationData.seeker.profile_pic)
                    : null,
                backgroundColor: Colors.grey[300],
                child: applicationData.seeker.profile_pic.isEmpty
                    ? const Icon(Icons.person, color: Colors.grey)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      applicationData.seeker.full_name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      applicationData.seeker.position,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Seeker Details
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow(
                  Icons.school,
                  'Education',
                  applicationData.seeker.education,
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  Icons.work_history,
                  'Experience',
                  applicationData.seeker.experience,
                ),
                const SizedBox(height: 8),
                _buildSkillsRow(applicationData.seeker.skills),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _openCV(applicationData.cvUrl),
                  icon: const Icon(Icons.description, size: 18),
                  label: const Text('View CV'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Contact feature coming soon!'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.email, size: 18),
                  label: const Text('Contact'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        Expanded(
          child: Text(
            value.isNotEmpty ? value : 'Not specified',
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildSkillsRow(List<String> skills) {
    return Row(
      children: [
        Icon(Icons.star, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        const Text(
          'Skills: ',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        Expanded(
          child: Wrap(
            spacing: 4,
            runSpacing: 4,
            children: skills.take(3).map((skill) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  skill,
                  style: TextStyle(fontSize: 12, color: Colors.blue[800]),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Future<void> _contactApplicant(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Application Discussion',
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        throw 'Could not launch email client';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to open email client: $e')),
      );
    }
  }
}
