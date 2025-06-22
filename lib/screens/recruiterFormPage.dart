import 'package:dream_seeker/screens/navigationPage.dart';
import 'package:flutter/material.dart';

class CompanyFormPage extends StatefulWidget {
  const CompanyFormPage({super.key});

  @override
  State<CompanyFormPage> createState() => _CompanyFormPageState();
}

class _CompanyFormPageState extends State<CompanyFormPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _industryController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

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
                // ...inside your build method...
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
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const Navigationpage(),
                        ),
                      );
                    }
                  },
                  child: const Text('Submit'),
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
        validator: (value) =>
            value == null || value.isEmpty ? 'Required' : null,
      ),
    );
  }
}
