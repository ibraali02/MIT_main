import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddCoursePage extends StatefulWidget {
  const AddCoursePage({super.key});

  @override
  State<AddCoursePage> createState() => _AddCoursePageState();
}

class _AddCoursePageState extends State<AddCoursePage> {
  final _courseTitleController = TextEditingController();
  final _courseDetailsController = TextEditingController();
  final _courseCategoryController = TextEditingController();
  final _courseStartDateController = TextEditingController();
  final _teacherNameController = TextEditingController();
  XFile? _selectedImage;
  bool _loading = false;

  // Function to upload image to Supabase Storage (No authentication check)
  Future<String?> uploadImageToSupabase(XFile? image) async {
    if (image == null) {
      print('Error: Image is null.');
      return null;
    }

    try {
      final imageBytes = await image.readAsBytes();
      final storagePath = 'courses/${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Log MIME type and image size for debugging
      print('MIME type: ${image.mimeType}');
      print('Image size: ${imageBytes.lengthInBytes} bytes');
      print('File path: ${image.path}');

      // Check the file extension to determine if it's a valid image
      final fileExtension = image.path.split('.').last.toLowerCase();
      final allowedExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp'];

      // Check if the file is an image by both MIME type and extension
      if (!allowedExtensions.contains(fileExtension) ||
          (image.mimeType != null && !image.mimeType!.startsWith('image'))) {
        print('Error: The selected file is not an image. Extension: $fileExtension, MIME: ${image.mimeType}');
        return null;
      }

      // Upload the image to Supabase Storage (without authentication check)
      final response = await Supabase.instance.client.storage.from('images').uploadBinary(
        storagePath,
        imageBytes,
        fileOptions: FileOptions(contentType: 'image/$fileExtension', upsert: true),
      );

      // Retrieve the public URL of the uploaded image
      final publicUrl = Supabase.instance.client.storage.from('images').getPublicUrl(storagePath);
      print('Image uploaded successfully: $publicUrl');
      return publicUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  // Function to add course data to Firestore
  Future<void> _addCourse() async {
    if (_loading) return;

    final title = _courseTitleController.text.trim();
    final details = _courseDetailsController.text.trim();
    final category = _courseCategoryController.text.trim();
    final startDate = _courseStartDateController.text.trim();
    final teacher = _teacherNameController.text.trim();

    if (title.isEmpty || details.isEmpty || category.isEmpty || startDate.isEmpty || teacher.isEmpty || _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields and select an image.')),
      );
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      final imageUrl = await uploadImageToSupabase(_selectedImage);

      if (imageUrl == null) {
        throw Exception('Image upload failed.');
      }

      await FirebaseFirestore.instance.collection('courses').add({
        'title': title,
        'details': details,
        'category': category,
        'start_date': startDate,
        'teacher': teacher,
        'image_url': imageUrl,
        'created_at': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Course added successfully!')),
      );

      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding course: $e')),
      );
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  // Function to pick an image from the gallery
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    try {
      final image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No image selected.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error selecting image.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Course')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(controller: _courseTitleController, label: 'Course Title'),
            _buildTextField(controller: _courseDetailsController, label: 'Course Details'),
            _buildTextField(controller: _courseCategoryController, label: 'Category'),
            _buildTextField(controller: _courseStartDateController, label: 'Start Date (YYYY-MM-DD)'),
            _buildTextField(controller: _teacherNameController, label: 'Teacher Name'),
            const SizedBox(height: 10),
            Row(
              children: [
                if (_selectedImage != null)
                  Image.file(File(_selectedImage!.path), height: 100),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: const Text('Select Image'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addCourse,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text('Add Course'),
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to build text fields
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
