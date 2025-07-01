import 'package:dream_seeker/models/jobModel.dart';
import 'package:dream_seeker/screens/jobDetailsPage.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends StatefulWidget {
  final VoidCallback? onSearchTap;
  const HomePage({super.key, this.onSearchTap});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<JobModel> allJobs = [];
  List<JobModel> featuredJobs = [];
  String? userFullName;
  String? userProfilePic;

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

  final List<Color> featuredAvatarColors = [
    Colors.pinkAccent,
    Colors.teal,
    Colors.amber,
    Colors.cyan,
    Colors.deepOrange,
    Colors.indigo,
    Colors.green,
    Colors.orange,
    Colors.purple,
  ];

  @override
  void initState() {
    super.initState();

    fetchUserData();
  }

  // Add these methods to fetch jobs as Futures for FutureBuilder
  Future<List<JobModel>> fetchAllJobsFuture() async {
    final response = await Supabase.instance.client
        .from('jobs')
        .select()
        .order('created_at', ascending: false);
    return (response as List)
        .map((job) => JobModel.fromJson(job as Map<String, dynamic>))
        .toList();
  }

  Future<List<JobModel>> fetchFeaturedJobsFuture() async {
    final response = await Supabase.instance.client
        .from('jobs')
        .select()
        .eq('featured', true)
        .order('created_at', ascending: false);
    return (response as List)
        .map((job) => JobModel.fromJson(job as Map<String, dynamic>))
        .toList();
  }

  Future<void> fetchUserData() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    final response = await Supabase.instance.client
        .from('seekers')
        .select('full_name, profile_pic')
        .eq('user_id', user.id)
        .single();
    setState(() {
      userFullName = response['full_name'] as String?;
      userProfilePic = response['profile_pic'] as String?;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              const Text(
                'Find a job',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildSearchBar(),
              const SizedBox(height: 24),
              const Text(
                'Featured jobs',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              FutureBuilder<List<JobModel>>(
                future: fetchFeaturedJobsFuture(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('No promoted jobs found.');
                  }
                  final jobs = snapshot.data!;
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: jobs.length,
                    itemBuilder: (context, index) {
                      return _buildJobCard(
                        jobs[index],
                        isPromoted: true,
                        color: featuredAvatarColors[index],
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'These jobs might interest you',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              FutureBuilder<List<JobModel>>(
                future: fetchAllJobsFuture(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('No jobs found.');
                  }
                  final jobs = snapshot.data!;
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: jobs.length,
                    itemBuilder: (context, index) {
                      return _buildJobCard(
                        jobs[index],
                        isPromoted: false,
                        color: avatarColors[index],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundImage:
              (userProfilePic != null && userProfilePic!.isNotEmpty)
              ? NetworkImage(userProfilePic!)
              : const NetworkImage(
                  'https://freesvg.org/img/business-man-avatar.png',
                ),
          backgroundColor: Colors.grey[300],
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              userFullName ?? 'User',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        const Spacer(),
        const Icon(Icons.notifications_none),
      ],
    );
  }

  Widget _buildSearchBar() {
    return InkWell(
      onTap: () {
        // Navigate to search page or show search dialog
        if (widget.onSearchTap != null) {
          widget.onSearchTap!();
        }
      },
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.0),
                    child: Icon(Icons.search, color: Colors.grey),
                  ),
                  const Expanded(
                    child: Text(
                      'Enter job title or keyword',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.tune, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildJobCard(
    JobModel job, {
    bool isPromoted = false,
    required Color color,
  }) {
    final Color cardColor = isPromoted ? Colors.indigo[400]! : Colors.white;
    final Color textColor = isPromoted ? Colors.white : Colors.black;
    final Color subTextColor = isPromoted ? Colors.white70 : Colors.grey[700]!;

    return GestureDetector(
      onTap: () {
        // Navigate to job details page
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => JobDetailsPage(job: job)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          border: isPromoted ? null : Border.all(color: Colors.grey.shade300),
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
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(job.company, style: TextStyle(color: subTextColor)),
                    ],
                  ),
                ),
                Icon(
                  Icons.bookmark,
                  color: isPromoted ? Colors.white : Colors.black,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(job.jobType, style: TextStyle(color: subTextColor)),
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
                        color: isPromoted
                            ? Colors.indigo[600]
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        req,
                        style: TextStyle(
                          color: isPromoted ? Colors.white : Colors.black,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                Text(job.salary, style: TextStyle(color: textColor)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
