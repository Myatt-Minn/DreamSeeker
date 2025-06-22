import 'package:flutter/material.dart';

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

  void _addRequirement() {
    final requirement = _requirementController.text.trim();
    if (requirement.isNotEmpty) {
      setState(() {
        _requirements.add(requirement);
        _requirementController.clear();
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
              _buildTextField(_jobTypeController, 'Job Type (e.g. Full-time)'),
              _buildTextField(_salaryController, 'Salary (e.g. \$50k - \$80k)'),
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
                    icon: const Icon(Icons.add, color: Colors.white),
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
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Submit job post
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('Job Posted')));
                  }
                },
                child: const Text('Submit'),
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
        validator: (value) =>
            value == null || value.isEmpty ? 'Required' : null,
      ),
    );
  }
}
