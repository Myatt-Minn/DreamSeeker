import 'dart:io';

import 'package:dream_seeker/screens/navigationPage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditSeekerProfilePage extends StatefulWidget {
  const EditSeekerProfilePage({super.key});

  @override
  State<EditSeekerProfilePage> createState() => _EditSeekerProfilePageState();
}

class _EditSeekerProfilePageState extends State<EditSeekerProfilePage> {
  final _formKey = GlobalKey<FormState>();
  File? _profileImage;
  final picker = ImagePicker();

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _educationController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _skillController = TextEditingController();
  final List<String> _skills = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    setState(() => _isLoading = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final response = await Supabase.instance.client
          .from('seekers')
          .select()
          .eq('user_id', user.id)
          .single();

      _fullNameController.text = response['full_name'] ?? '';
      _experienceController.text = response['experience'] ?? '';
      _educationController.text = response['education'] ?? '';
      _positionController.text = response['position'] ?? '';
      if (response['skills'] != null && response['skills'] is List) {
        _skills.addAll(List<String>.from(response['skills']));
      }
      if (response['profile_pic'] != null &&
          response['profile_pic'].toString().isNotEmpty) {
        // Optionally, you can display the network image as a preview
        // For editing, user can pick a new image
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load profile: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

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
    if (skill.isNotEmpty && !_skills.contains(skill)) {
      setState(() {
        _skills.add(skill);
        _skillController.clear();
      });
    }
  }

  Future<void> _updateProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('User not found.')));
        return;
      }

      String profilePicUrl = '';
      if (_profileImage != null) {
        final fileName = DateTime.now().microsecondsSinceEpoch.toString();
        await Supabase.instance.client.storage
            .from('profilepics')
            .upload(
              fileName,
              _profileImage!,
              fileOptions: const FileOptions(upsert: true),
            );

        profilePicUrl = Supabase.instance.client.storage
            .from('profilepics')
            .getPublicUrl(fileName);
      }

      final data = {
        'full_name': _fullNameController.text.trim(),
        'experience': _experienceController.text.trim(),
        'education': _educationController.text.trim(),
        'position': _positionController.text.trim(),
        'skills': _skills,
      };
      if (profilePicUrl.isNotEmpty) {
        data['profile_pic'] = profilePicUrl;
      }

      await Supabase.instance.client
          .from('seekers')
          .update(data)
          .eq('user_id', user.id);

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const Navigationpage()),
      );
    } catch (e) {
      setState(() => _isLoading = false);
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
          'Edit Profile',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: Center(
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
                                    fit: BoxFit.cover,
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
                      leadingIcon: const Icon(
                        Icons.person,
                        color: Colors.black54,
                      ),
                    ),
                    _buildTextField(
                      _experienceController,
                      'Experience',
                      leadingIcon: const Icon(
                        Icons.timeline,
                        color: Colors.black54,
                      ),
                    ),
                    _buildTextField(
                      _educationController,
                      'Education',
                      leadingIcon: const Icon(
                        Icons.school,
                        color: Colors.black54,
                      ),
                    ),
                    _buildTextField(
                      _positionController,
                      'Position',
                      leadingIcon: const Icon(
                        Icons.work,
                        color: Colors.black54,
                      ),
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
                                await _updateProfile();
                              } else if (_skills.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Please add at least one skill.',
                                    ),
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
                          : const Text('Save Changes'),
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
    Icon? leadingIcon,
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
        validator: (value) {
          if (isSkillField) {
            return null;
          }
          if (value == null || value.isEmpty) {
            return 'Required';
          }
          return null;
        },
      ),
    );
  }
}
