import 'dart:io';

import 'package:dream_seeker/models/recruiterModel.dart';
import 'package:dream_seeker/screens/recruiterNavigation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CompanyFormPage extends StatefulWidget {
  const CompanyFormPage({super.key});

  @override
  State<CompanyFormPage> createState() => _CompanyFormPageState();
}

class _CompanyFormPageState extends State<CompanyFormPage> {
  final _formKey = GlobalKey<FormState>();
  File? _profileImage;
  final picker = ImagePicker();

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _industryController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitRecruiterData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      // Sign up the user
      final authResponse = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );

      final user = authResponse.user;
      if (user == null) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Sign up failed.')));
        return;
      }

      String profilePicUrl = '';
      if (_profileImage != null) {
        final fileName = DateTime.now().millisecondsSinceEpoch.toString();
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
        'role': 'recruiter',
      };

      await Supabase.instance.client.from('users').insert(userData);
      // Create RecruiterModel instance
      final recruiter = RecruiterModel(
        id: 0, // Supabase will auto-generate
        userId: user.id,
        email: email,
        password: password,
        profilePic: profilePicUrl,
        fullName: _fullNameController.text.trim(),
        companyName: _companyNameController.text.trim(),
        companyWebsite: _websiteController.text.trim(),
        companyLocation: _locationController.text.trim(),
        companyDescription: _descriptionController.text.trim(),
        createdAt: DateTime.now(),
      );

      final data = recruiter.toJson();
      data.remove('id'); // Remove id so Supabase can auto-generate
      data.remove('created_at'); // Remove created_at if Supabase handles it

      final response = await Supabase.instance.client
          .from('recruiters')
          .insert(data);

      setState(() {
        _isLoading = false;
      });

      if (response == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile created successfully!')),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const Recruiternavigation()),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $response')));
      }
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
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
        title: const Text(
          'Company Info Form',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
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
                  _companyNameController,
                  'Company Name',
                  leadingIcon: const Icon(
                    Icons.business,
                    color: Colors.black54,
                  ),
                ),
                _buildTextField(
                  _industryController,
                  'Industry',
                  leadingIcon: const Icon(
                    Icons.category,
                    color: Colors.black54,
                  ),
                ),
                _buildTextField(
                  _locationController,
                  'Location',
                  leadingIcon: const Icon(
                    Icons.location_on,
                    color: Colors.black54,
                  ),
                ),
                _buildTextField(
                  _websiteController,
                  'Website',
                  leadingIcon: const Icon(Icons.link, color: Colors.black54),
                ),
                _buildTextField(
                  _descriptionController,
                  'Company Description',
                  maxLines: 4,
                  leadingIcon: const Icon(
                    Icons.description,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _isLoading
                      ? null
                      : () {
                          if (_formKey.currentState!.validate()) {
                            _submitRecruiterData();
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
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hintText, {
    int maxLines = 1,
    Icon? leadingIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: leadingIcon,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        ),
        obscureText: hintText.toLowerCase() == 'password',
        validator: (value) {
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
