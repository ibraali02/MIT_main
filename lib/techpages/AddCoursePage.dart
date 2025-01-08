import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts

class AddCoursePage extends StatefulWidget {
  const AddCoursePage({super.key});

  @override
  State<AddCoursePage> createState() => _AddCoursePageState();
}

class _AddCoursePageState extends State<AddCoursePage> {
  final _courseTitleController = TextEditingController();
  final _courseDetailsController = TextEditingController();
  final _teacherNameController = TextEditingController();
  XFile? _selectedImage;
  bool _loading = false;
  String _selectedCategory = 'التكنولوجيا'; // default category in Arabic

  // List of categories in Arabic for the DropdownButton
  final List<String> categories = [
    'الكل',
    'التكنولوجيا',
    'تكنولوجيا المعلومات',
    'لغات البرمجة',
    'الأمن السيبراني',
    'علوم البيانات',
    'تطوير الويب',
    'تطوير التطبيقات المحمولة',
    'الذكاء الاصطناعي',
  ];

  // Function to upload image to Supabase Storage
  Future<String?> uploadImageToSupabase(XFile? image) async {
    if (image == null) {
      print('Error: Image is null.');
      return null;
    }

    try {
      final imageBytes = await image.readAsBytes();
      final storagePath = 'courses/${DateTime.now().millisecondsSinceEpoch}.jpg';

      final fileExtension = image.path.split('.').last.toLowerCase();
      final allowedExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp'];

      if (!allowedExtensions.contains(fileExtension) ||
          (image.mimeType != null && !image.mimeType!.startsWith('image'))) {
        print('Error: The selected file is not an image.');
        return null;
      }

      final response = await Supabase.instance.client.storage.from('images').uploadBinary(
        storagePath,
        imageBytes,
        fileOptions: FileOptions(contentType: 'image/$fileExtension', upsert: true),
      );

      final publicUrl = Supabase.instance.client.storage.from('images').getPublicUrl(storagePath);
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
    final category = _selectedCategory;
    final teacher = _teacherNameController.text.trim();

    if (title.isEmpty || details.isEmpty || teacher.isEmpty || _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى ملء جميع الحقول واختيار صورة.')),
      );
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        throw Exception('لم يتم العثور على رمز المستخدم. يرجى تسجيل الدخول مرة أخرى.');
      }

      final imageUrl = await uploadImageToSupabase(_selectedImage);

      if (imageUrl == null) {
        throw Exception('فشل تحميل الصورة.');
      }

      // Store the course data along with the current timestamp
      await FirebaseFirestore.instance.collection('courses').add({
        'title': title,
        'details': details,
        'category': category,
        'teacher': teacher,
        'image_url': imageUrl,
        'created_at': Timestamp.now(), // تخزين وقت النشر
        'token': token,
        'isCompleted': false,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إضافة الدورة بنجاح!')),
      );

      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في إضافة الدورة: $e')),
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
          const SnackBar(content: Text('لم يتم اختيار صورة.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('خطأ في اختيار الصورة.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إضافة دورة', style: GoogleFonts.cairo()), // Apply Cairo font
        backgroundColor: const Color(0xFF0096AB),
        centerTitle: true,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(controller: _courseTitleController, label: 'عنوان الدورة'),
            _buildTextField(controller: _courseDetailsController, label: 'تفاصيل الدورة'),
            // Dropdown menu for category selection
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blueAccent, Colors.lightBlue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 3,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCategory = newValue!;
                    });
                  },
                  items: categories.map<DropdownMenuItem<String>>((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(
                        category,
                        style: GoogleFonts.cairo( // Apply Cairo font
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }).toList(),
                  dropdownColor: Colors.blueAccent,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
            _buildTextField(controller: _teacherNameController, label: 'اسم المعلم'),
            const SizedBox(height: 10),
            Row(
              children: [
                if (_selectedImage != null)
                  Image.file(File(_selectedImage!.path), height: 100),
                ElevatedButton(
                  onPressed: _pickImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEFAC52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  child: Text('اختر صورة', style: GoogleFonts.cairo(color: Colors.white)), // Apply Cairo font
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addCourse,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0096AB),
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text('إضافة دورة', style: GoogleFonts.cairo(fontSize: 16, color: Colors.white)), // Apply Cairo font
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
        style: GoogleFonts.cairo(), // Apply Cairo font
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.black.withOpacity(0.7),
            fontWeight: FontWeight.w600, // Bold label text
          ),
          filled: true,
          fillColor: Colors.blueGrey[50], // Light background color
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16), // Rounded corners
            borderSide: const BorderSide(color: Color(0xFF0096AB), width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF0096AB), width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF0096AB), width: 2),
          ),
        ),
      ),
    );
  }
}