import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart'; // استيراد مكتبة Google Fonts

class LecturesPage extends StatefulWidget {
  final String courseId;

  const LecturesPage({super.key, required this.courseId});

  @override
  _LecturesPageState createState() => _LecturesPageState();
}

class _LecturesPageState extends State<LecturesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Directionality(
        textDirection: TextDirection.rtl, // تعيين اتجاه النص من اليمين لليسار
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('courses')
              .doc(widget.courseId)
              .collection('lectures')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('لا توجد محاضرات متاحة.'));
            }

            final lectures = snapshot.data!.docs;

            return ListView.builder(
              itemCount: lectures.length,
              itemBuilder: (context, index) {
                final lecture = lectures[index];
                final lectureName = lecture['lectureName'];
                final description = lecture['description'];
                final professorName = lecture['professorName'];
                final fileUrl = lecture['fileUrl'];

                return Card(
                  margin: const EdgeInsets.all(8.0),
                  color: const Color(0xFFF5F5F5),
                  child: ListTile(
                    title: Text(
                      lectureName,
                      style: GoogleFonts.cairo( // استخدام خط Cairo
                        color: const Color(0xFF0096AB),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'الأستاذ: $professorName\n$description',
                      style: GoogleFonts.cairo( // استخدام خط Cairo
                        color: Colors.black,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.picture_as_pdf, color: Color(0xFFEFAC52)),
                      onPressed: () async {
                        if (fileUrl.isNotEmpty) {
                          try {
                            await launchUrl(
                              Uri.parse(fileUrl),
                              mode: LaunchMode.externalApplication,
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('لم نتمكن من فتح ملف PDF: $e')),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('رابط الملف غير صالح')),
                          );
                        }
                      },
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class UploadLecturePage extends StatefulWidget {
  final String courseId;

  const UploadLecturePage({super.key, required this.courseId});

  @override
  _UploadLecturePageState createState() => _UploadLecturePageState();
}

class _UploadLecturePageState extends State<UploadLecturePage> {
  final TextEditingController lectureNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController professorNameController = TextEditingController();
  FilePickerResult? _selectedFile;

  Future<void> _uploadPdf(BuildContext context) async {
    try {
      if (_selectedFile == null || _selectedFile!.files.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لم يتم اختيار ملف')),
        );
        return;
      }

      final file = _selectedFile!.files.first;
      final filePath = file.path;
      final fileName = file.name;

      if (filePath == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('خطأ: مسار الملف فارغ')),
        );
        return;
      }

      final storagePath = 'courses/${widget.courseId}/$fileName';
      await Supabase.instance.client.storage
          .from('lecture')
          .upload(
        storagePath,
        File(filePath),
        fileOptions: const FileOptions(contentType: 'application/pdf'),
      );

      final downloadUrl = Supabase.instance.client.storage
          .from('lecture')
          .getPublicUrl(storagePath);

      await FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.courseId)
          .collection('lectures')
          .add({
        'lectureName': lectureNameController.text,
        'description': descriptionController.text,
        'professorName': professorNameController.text,
        'fileUrl': downloadUrl,
        'createdAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم رفع المحاضرة بنجاح')),
      );

      setState(() {
        _selectedFile = null;
        lectureNameController.clear();
        descriptionController.clear();
        professorNameController.clear();
      });

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في رفع المحاضرة: $e')),
      );
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result == null || result.files.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لم يتم اختيار ملف')),
      );
      return;
    }

    setState(() {
      _selectedFile = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0096AB),
        title: Text(
          'رفع محاضرة',
          style: GoogleFonts.cairo(color: Colors.white), // استخدام خط Cairo
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl, // تعيين اتجاه النص من اليمين لليسار
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: lectureNameController,
                decoration: InputDecoration(
                  labelText: 'اسم المحاضرة',
                  labelStyle: GoogleFonts.cairo(), // استخدام خط Cairo
                ),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'الوصف',
                  labelStyle: GoogleFonts.cairo(), // استخدام خط Cairo
                ),
              ),
              TextField(
                controller: professorNameController,
                decoration: InputDecoration(
                  labelText: 'اسم الأستاذ',
                  labelStyle: GoogleFonts.cairo(), // استخدام خط Cairo
                ),
              ),
              const SizedBox(height: 20),
              _selectedFile != null
                  ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('الملف المختار: ${_selectedFile!.files.first.name}', style: GoogleFonts.cairo()), // استخدام خط Cairo
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => _uploadPdf(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEFAC52),
                    ),
                    child: const Text('حفظ المحاضرة'),
                  ),
                ],
              )
                  : ElevatedButton(
                onPressed: _pickFile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEFAC52),
                ),
                child: const Text('اختيار ملف PDF'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
