import 'dart:io';

import 'package:dream_seeker/models/applicationModel.dart';
import 'package:dream_seeker/models/jobModel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class JobDetailsPage extends StatelessWidget {
  final JobModel job;

  const JobDetailsPage({super.key, required this.job});

  Future<void> _applyForJob(BuildContext context) async {
    try {
      // Pick file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );
      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('You must be logged in.')));
        return;
      }

      // Upload file to Supabase Storage
      final fileBytes = file.bytes ?? await File(file.path!).readAsBytes();
      final fileName =
          '${user.id}_${DateTime.now().millisecondsSinceEpoch}_${file.name}';
      final storageResponse = await Supabase.instance.client.storage
          .from('profilepics')
          .uploadBinary(fileName, fileBytes);

      if (storageResponse.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to upload CV.')));
        return;
      }

      final cvUrl = Supabase.instance.client.storage
          .from('profilepics')
          .getPublicUrl(fileName);

      Applicationmodel application = Applicationmodel(
        seekerId: user.id,
        cv: cvUrl,
        jobId: job.id,
      );
      // Insert application row
      await Supabase.instance.client
          .from('applications')
          .insert(application.toJson());

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Application submitted!')));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat.yMMMd().format(job.postedAt);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Job Details', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (job.featured)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Featured Job',
                    style: TextStyle(color: Colors.deepOrange),
                  ),
                ),
              const SizedBox(height: 10),

              Text(
                job.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                job.company,
                style: const TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 18,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    job.location,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Chip(label: Text(job.jobType)),
                    const SizedBox(width: 10),
                    Chip(label: Text(job.salary)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Job Description',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                job.description,
                style: const TextStyle(fontSize: 15, height: 1.5),
              ),

              const SizedBox(height: 24),
              const Text(
                'Requirements',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: job.requirements
                    .map(
                      (req) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              size: 18,
                              color: Colors.green,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                req,
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),

              const SizedBox(height: 24),
              Text(
                'Posted on $formattedDate',
                style: const TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _applyForJob(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Apply Now (Choose CV file)',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
