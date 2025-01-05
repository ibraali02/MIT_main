import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart'; // Ensure Supabase is configured
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _degreeController = TextEditingController();
  final TextEditingController _collegeController = TextEditingController();
  FilePickerResult? _selectedFile;
  bool _isLoading = false;
  bool _isAccepted = false; // To track if the request has been accepted

  Future<void> _pickFile() async {
    try {
      _selectedFile = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
      if (_selectedFile == null || _selectedFile!.files.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No file selected')),
        );
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selected file: ${_selectedFile!.files.first.name}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error selecting file')),
      );
    }
  }

  Future<void> _uploadPdfAndSendRequest() async {
    setState(() {
      _isLoading = true;
    });

    try {
      String fullName = _fullNameController.text;
      String email = _emailController.text;
      String phone = _phoneController.text;
      String password = _passwordController.text;
      String degree = _degreeController.text;
      String college = _collegeController.text;

      if (_selectedFile == null || _selectedFile!.files.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No file selected')),
        );
        return;
      }

      final file = _selectedFile!.files.first;
      final filePath = file.path;
      final fileName = file.name;

      if (filePath == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: File path is null')),
        );
        return;
      }

      final storagePath = 'teachers_pdfs/$fileName';
      await Supabase.instance.client.storage.from('lecture').upload(
        storagePath,
        File(filePath),
        fileOptions: const FileOptions(contentType: 'application/pdf'),
      );

      final downloadUrl = Supabase.instance.client.storage
          .from('lecture')
          .getPublicUrl(storagePath);

      // Check if the collection exists
      var collectionRef = FirebaseFirestore.instance.collection('teacher_requests');

      // Add a new document with accepted: false
      await collectionRef.add({
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'password': password,
        'degree': degree,
        'college': college,
        'cvUrl': downloadUrl,
        'requestTime': Timestamp.now(),
        'accepted': false, // Set accepted to false by default
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request sent and CV uploaded successfully!')),
      );
    } catch (e) {
      // Log error details
      print("Error details: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: const Text(
            'Your information will be sent to the app owner. Once verified and approved, you will receive your login details via email or phone.',
            style: TextStyle(fontSize: 16),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                if (_fullNameController.text.isNotEmpty &&
                    _emailController.text.isNotEmpty &&
                    _phoneController.text.isNotEmpty &&
                    _passwordController.text.isNotEmpty &&
                    _degreeController.text.isNotEmpty &&
                    _collegeController.text.isNotEmpty) {
                  await _uploadPdfAndSendRequest();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields')),
                  );
                }
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _checkIfAccepted(String documentId) async {
    // Retrieve the approval status from Firestore to check if the request has been accepted
    var doc = await FirebaseFirestore.instance.collection('teacher_requests').doc(documentId).get();
    if (doc.exists) {
      setState(() {
        _isAccepted = doc['accepted']; // Get the approval status from Firestore
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up as a Teacher', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0096AB),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _fullNameController,
              decoration: const InputDecoration(labelText: 'Full Name'),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Phone'),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            TextField(
              controller: _degreeController,
              decoration: const InputDecoration(labelText: 'Degree'),
            ),
            TextField(
              controller: _collegeController,
              decoration: const InputDecoration(labelText: 'College'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickFile,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0096AB),
              ),
              child: const Text('Select CV (PDF)', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 20),
            // Only show the "Send Request" button if the request has not been accepted yet
            if (!_isAccepted)
              ElevatedButton(
                onPressed: _showConfirmationDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEFAC52),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Send Request', style: TextStyle(color: Colors.white)),
              ),
          ],
        ),
      ),
    );
  }
}
