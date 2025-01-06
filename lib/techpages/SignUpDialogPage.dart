import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
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
  bool _isAccepted = false;

  Future<void> _pickFile() async {
    try {
      _selectedFile = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (_selectedFile == null || _selectedFile!.files.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لم يتم اختيار ملف')),
        );
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم اختيار الملف: ${_selectedFile!.files.first.name}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حدث خطأ أثناء اختيار الملف')),
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
          const SnackBar(content: Text('لم يتم اختيار ملف')),
        );
        return;
      }

      final file = _selectedFile!.files.first;
      final filePath = file.path;
      final randomFileName =
          '${DateTime.now().millisecondsSinceEpoch}_${file.name}';

      if (filePath == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('خطأ: مسار الملف فارغ')),
        );
        return;
      }

      final storagePath = 'teachers_pdfs/$randomFileName';
      await Supabase.instance.client.storage.from('lecture').upload(
        storagePath,
        File(filePath),
        fileOptions: const FileOptions(contentType: 'application/pdf'),
      );

      final downloadUrl = Supabase.instance.client.storage
          .from('lecture')
          .getPublicUrl(storagePath);

      var collectionRef =
      FirebaseFirestore.instance.collection('teacher_requests');

      await collectionRef.add({
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'password': password,
        'degree': degree,
        'college': college,
        'cvUrl': downloadUrl,
        'requestTime': Timestamp.now(),
        'accepted': false,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إرسال الطلب وتحميل السيرة الذاتية بنجاح!')),
      );
    } catch (e) {
      print("Error details: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: ${e.toString()}')),
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
          title: Text(
            'تأكيد',
            style: GoogleFonts.cairo(fontSize: 18),
          ),
          content: Text(
            'سيتم إرسال معلوماتك إلى صاحب التطبيق. بمجرد التحقق والموافقة، ستتلقى تفاصيل تسجيل الدخول عبر البريد الإلكتروني أو الهاتف.',
            style: GoogleFonts.cairo(fontSize: 16),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('إلغاء', style: GoogleFonts.cairo()),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                if (_fullNameController.text.isNotEmpty &&
                    _emailController.text.isNotEmpty &&
                    _phoneController.text.isNotEmpty &&
                    _passwordController.text.isNotEmpty &&
                    _degreeController.text.isNotEmpty &&
                    _collegeController.text.isNotEmpty) {
                  await _uploadPdfAndSendRequest();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('يرجى ملء جميع الحقول')),
                  );
                }
              },
              child: Text('تأكيد', style: GoogleFonts.cairo(fontSize: 16)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'التسجيل كمعلم',
          style: GoogleFonts.cairo(color: Colors.white, fontSize: 18),
        ),
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
            _buildTextField(_fullNameController, 'الاسم الكامل'),
            _buildTextField(_emailController, 'البريد الإلكتروني',
                keyboardType: TextInputType.emailAddress),
            _buildTextField(_phoneController, 'رقم الهاتف',
                keyboardType: TextInputType.phone),
            _buildTextField(_passwordController, 'كلمة المرور',
                obscureText: true),
            _buildTextField(_degreeController, 'الشهادة الجامعية'),
            _buildTextField(_collegeController, 'الكلية'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickFile,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0096AB),
                padding:
                const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                textStyle: GoogleFonts.cairo(fontSize: 18),
              ),
              child: const Text('اختيار السيرة الذاتية (PDF)',
                  style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 20),
            if (!_isAccepted)
              ElevatedButton(
                onPressed: _showConfirmationDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEFAC52),
                  padding:
                  const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                  textStyle: GoogleFonts.cairo(fontSize: 20),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('إرسال الطلب',
                    style: TextStyle(color: Colors.white)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String labelText, {
        TextInputType keyboardType = TextInputType.text,
        bool obscureText = false,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: GoogleFonts.cairo(fontSize: 16),
        textDirection: TextDirection.rtl,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle:
          GoogleFonts.cairo(fontSize: 14, color: const Color(0xFF9E9E9E)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
                color: Color(0xFF0096AB), width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
                color: Color(0xFF0096AB), width: 2),
          ),
          contentPadding:
          const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
      ),
    );
  }
}
