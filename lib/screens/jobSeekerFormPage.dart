import 'dart:io';

import 'package:dream_seeker/screens/navigationPage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class JobSeekerFormPage extends StatefulWidget {
  const JobSeekerFormPage({super.key});

  @override
  State<JobSeekerFormPage> createState() => _JobSeekerFormPageState();
}

class _JobSeekerFormPageState extends State<JobSeekerFormPage> {
  final _formKey = GlobalKey<FormState>();
  File? _profileImage;
  final picker = ImagePicker();

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _educationController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _skillController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final List<String> _skills = [];

  bool _isLoading = false; // Add this line

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  void _addSkill() {
    final skill = _skillController.text.trim();
    if (skill.isNotEmpty) {
      setState(() {
        _skills.add(skill);
        _skillController.clear();
      });
    }
  }

  Future<void> _submitToSupabase() async {
    setState(() {
      _isLoading = true; // Start loading
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      final authResponse = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );

      final user = authResponse.user;
      if (user == null) {
        setState(() {
          _isLoading = false; // Stop loading
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Sign up failed.')));
        return;
      }

      String profilePicUrl = '';
      if (_profileImage != null) {
        final fileName = '${user.id}_profile_pic.jpg';
        await Supabase.instance.client.storage
            .from('profilepics')
            .upload(fileName, _profileImage!);

        profilePicUrl = Supabase.instance.client.storage
            .from('profilepics')
            .getPublicUrl(fileName);
      }
      final userData = {
        'user_id': user.id,
        'email': email,
        'password': password,
        'role': 'seeker',
      };

      await Supabase.instance.client.from('users').insert(userData);
      final data = {
        'user_id': user.id,
        'email': email,
        'password': password,
        'profile_pic': profilePicUrl,
        'full_name': _fullNameController.text.trim(),
        'experience': _experienceController.text.trim(),
        'education': _educationController.text.trim(),
        'position': _positionController.text.trim(),
        'skills': _skills,
      };

      await Supabase.instance.client.from('seekers').insert(data);

      setState(() {
        _isLoading = false; // Stop loading
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile created successfully!')),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const Navigationpage()),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('An error occurred: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text(
          'Job Seeker Form',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Center(
                  // Keeps the circle centered and avoids full width
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[300],
                    ),
                    child: _profileImage != null
                        ? ClipOval(
                            child: Image.file(
                              _profileImage!,
                              width: 120,
                              height: 120,
                              fit: BoxFit
                                  .cover, // Ensures image fills the circle
                            ),
                          )
                        : const Center(
                            child: Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              _buildTextField(
                _fullNameController,
                'Full Name',
                leadingIcon: const Icon(Icons.person, color: Colors.black54),
              ),
              _buildTextField(
                _emailController,
                'Email',
                leadingIcon: const Icon(Icons.email, color: Colors.black54),
              ),
              _buildTextField(
                _passwordController,
                'Password',
                leadingIcon: const Icon(Icons.lock, color: Colors.black54),
              ),
              _buildTextField(
                _experienceController,
                'Experience',
                leadingIcon: const Icon(Icons.timeline, color: Colors.black54),
              ),
              _buildTextField(
                _educationController,
                'Education',
                leadingIcon: const Icon(Icons.school, color: Colors.black54),
              ),
              _buildTextField(
                _positionController,
                'Position',
                leadingIcon: const Icon(Icons.work, color: Colors.black54),
              ),

              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      _skillController,
                      'Add Skill',
                      suffixIcon: null,
                      isSkillField: true,
                      leadingIcon: const Icon(
                        Icons.star,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.black),
                    onPressed: _addSkill,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _skills
                    .map(
                      (skill) => Chip(
                        backgroundColor: Colors.white,
                        label: Text(
                          skill,
                          style: const TextStyle(color: Colors.black),
                        ),
                        deleteIcon: const Icon(Icons.close),
                        onDeleted: () {
                          setState(() => _skills.remove(skill));
                        },
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _isLoading
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate() &&
                            _skills.isNotEmpty) {
                          await _submitToSupabase();
                        } else if (_skills.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please add at least one skill.'),
                            ),
                          );
                        }
                      },
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
    bool isSkillField = false,
    Icon? leadingIcon, // <-- Accept icon as parameter
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          prefixIcon: leadingIcon,
          suffixIcon: suffixIcon,
        ),
        obscureText: hintText.toLowerCase() == 'password',
        validator: (value) {
          if (isSkillField) {
            return null;
          }
          if (hintText.toLowerCase() == 'password') {
            if (value == null || value.isEmpty) {
              return 'Required';
            }
            if (value.length < 6) {
              return 'Password must be at least 6 characters';
            }
          } else if (value == null || value.isEmpty) {
            return 'Required';
          }
          return null;
        },
      ),
    );
  }
}
