import 'package:dream_seeker/models/jobModel.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ApplicationsPage extends StatefulWidget {
  const ApplicationsPage({super.key});

  @override
  State<ApplicationsPage> createState() => _ApplicationsPageState();
}

class _ApplicationsPageState extends State<ApplicationsPage> {
  List<JobModel> appliedJobs = [];

  @override
  void initState() {
    super.initState();

    fetchAppliedJobs();
  }

  Future<void> fetchAppliedJobs() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {}

      // Fetch applications for current user
      final applications = await Supabase.instance.client
          .from('applications')
          .select('job_id')
          .eq('seeker_id', user!.id);

      if (applications.isEmpty) {
        setState(() {
          appliedJobs = [];
        });

        return;
      }

      final jobIds = (applications as List)
          .map((app) => app['job_id'])
          .where((id) => id != null)
          .toList();

      if (jobIds.isEmpty) {
        setState(() {
          appliedJobs = [];
        });

        return;
      }

      final jobsResponse = await Supabase.instance.client
          .from('jobs')
          .select()
          .filter('id', 'in', '(${jobIds.join(",")})');

      setState(() {
        appliedJobs = (jobsResponse as List)
            .map((job) => JobModel.fromJson(job as Map<String, dynamic>))
            .toList();
      });
      print("GGGGG");
    } catch (e) {
      setState(() {
        appliedJobs = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load applications: $e')),
      );
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
        leading: SizedBox(),
        title: const Text(
          'My Applications',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: appliedJobs.isEmpty
            ? const Center(
                child: Text(
                  '',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
            : ListView.builder(
                itemCount: appliedJobs.length,
                itemBuilder: (context, index) {
                  final job = appliedJobs[index];
                  final color = avatarColors[index % avatarColors.length];
                  return _buildJobCard(job, color: color);
                },
              ),
      ),
    );
  }

  Widget _buildJobCard(JobModel job, {required Color color}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: color,
                child: const Icon(Icons.work, color: Colors.black),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.title,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      job.company,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.check_circle, color: Colors.green),
            ],
          ),
          const SizedBox(height: 12),
          Text(job.jobType, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: job.requirements.map((req) {
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      req,
                      style: const TextStyle(color: Colors.black),
                    ),
                  );
                }).toList(),
              ),
              Text(job.salary, style: const TextStyle(color: Colors.black)),
            ],
          ),
        ],
      ),
    );
  }
}
