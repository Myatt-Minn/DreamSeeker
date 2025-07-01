import 'package:dream_seeker/models/jobModel.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Jobpostformpage extends StatefulWidget {
  const Jobpostformpage({super.key});

  @override
  State<Jobpostformpage> createState() => _JobpostformpageState();
}

class _JobpostformpageState extends State<Jobpostformpage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _jobTitleController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _jobTypeController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();
  final TextEditingController _requirementController = TextEditingController();

  final List<String> _requirements = [];
  bool _isLoading = false;

  void _addRequirement() {
    final requirement = _requirementController.text.trim();
    if (requirement.isNotEmpty) {
      setState(() {
        _requirements.add(requirement);
        _requirementController.clear();
      });
    }
  }

  Future<void> _submitJob() async {
    // Validate form fields except requirements
    if (!_formKey.currentState!.validate()) return;

    // Validate that at least one requirement is added
    if (_requirements.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one requirement.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final job = JobModel(
        title: _jobTitleController.text.trim(),
        company: _companyController.text.trim(),
        location: _locationController.text.trim(),
        description: _descriptionController.text.trim(),
        jobType: _jobTypeController.text.trim(),
        salary: _salaryController.text.trim(),
        requirements: _requirements,
        postedAt: DateTime.now(),
        featured: false,
      );

      final data = job.toJson();
      data.remove('id'); // Let Supabase auto-generate

      await Supabase.instance.client.from('jobs').insert(data);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Job Posted!')));
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
        title: const Text('Post a Job', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(_jobTitleController, 'Job Title'),
              _buildTextField(_companyController, 'Company Name'),
              _buildTextField(_locationController, 'Location'),
              _buildTextField(
                _descriptionController,
                'Job Description',
                maxLines: 4,
              ),
              _buildTextField(
                _jobTypeController,
                'Job Type (e.g. Full-time, Remote)',
              ),
              _buildTextField(_salaryController, 'Salary (e.g. 50K/ year)'),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      _requirementController,
                      'Add Requirement',
                      suffixIcon: null,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.black),
                    onPressed: _addRequirement,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _requirements
                    .map(
                      (req) => Chip(
                        backgroundColor: Colors.white,
                        label: Text(
                          req,
                          style: const TextStyle(color: Colors.black),
                        ),
                        deleteIcon: const Icon(Icons.close),
                        onDeleted: () {
                          setState(() => _requirements.remove(req));
                        },
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _isLoading ? null : _submitJob,
                child: _isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hintText, {
    Widget? suffixIcon,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hintText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          suffixIcon: suffixIcon,
        ),
        // Do not validate for requirement field
        validator: (value) {
          if (controller == _requirementController) {
            return null;
          }
          return value == null || value.isEmpty ? 'Required' : null;
        },
      ),
    );
  }
}
