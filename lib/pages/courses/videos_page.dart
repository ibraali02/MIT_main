import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';

class VideosPage extends StatefulWidget {
  final String courseId;

  const VideosPage({super.key, required this.courseId});

  @override
  _VideosPageState createState() => _VideosPageState();
}

class _VideosPageState extends State<VideosPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('courses')
            .doc(widget.courseId)
            .collection('videos')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('لا توجد مقاطع فيديو.'));
          }

          final videos = snapshot.data!.docs;

          return ListView.builder(
            itemCount: videos.length,
            itemBuilder: (context, index) {
              final video = videos[index];
              final videoName = video['videoName'];
              final description = video['description'];
              final fileUrl = video['fileUrl'];

              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(
                    videoName,
                    style: TextStyle(fontFamily: 'Cairo'),
                  ),
                  subtitle: Text(
                    description,
                    style: TextStyle(fontFamily: 'Cairo'),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.play_circle_fill, color: Color(0xFFEFAC52)),
                    onPressed: () async {
                      if (fileUrl.isNotEmpty) {
                        try {
                          await launchUrl(
                            Uri.parse(fileUrl),
                            mode: LaunchMode.externalApplication,
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('تعذر فتح الفيديو: $e')),
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
    );
  }
}

class UploadVideoPage extends StatefulWidget {
  final String courseId;

  const UploadVideoPage({super.key, required this.courseId});

  @override
  _UploadVideoPageState createState() => _UploadVideoPageState();
}

class _UploadVideoPageState extends State<UploadVideoPage> {
  final TextEditingController videoNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  FilePickerResult? _selectedFile;

  Future<void> _uploadVideo(BuildContext context) async {
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

      final storagePath = 'courses/${widget.courseId}/videos/$fileName';
      await Supabase.instance.client.storage
          .from('videos')
          .upload(
        storagePath,
        File(filePath),
        fileOptions: const FileOptions(contentType: 'video/mp4'),
      );

      final downloadUrl = Supabase.instance.client.storage
          .from('videos')
          .getPublicUrl(storagePath);

      await FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.courseId)
          .collection('videos')
          .add({
        'videoName': videoNameController.text,
        'description': descriptionController.text,
        'fileUrl': downloadUrl,
        'createdAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تحميل الفيديو بنجاح')),
      );

      setState(() {
        _selectedFile = null;
        videoNameController.clear();
        descriptionController.clear();
      });

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في تحميل الفيديو: $e')),
      );
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp4', 'mov', 'avi'],
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
        automaticallyImplyLeading: false,
        title: const Text('تحميل فيديو', style: TextStyle(fontFamily: 'Cairo')),
        backgroundColor: const Color(0xFF0096AB),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: videoNameController,
              decoration: const InputDecoration(
                labelText: 'اسم الفيديو',
                labelStyle: TextStyle(color: Color(0xFF0096AB), fontFamily: 'Cairo'),
              ),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'الوصف',
                labelStyle: TextStyle(color: Color(0xFF0096AB), fontFamily: 'Cairo'),
              ),
            ),
            const SizedBox(height: 20),
            _selectedFile != null
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('الملف المختار: ${_selectedFile!.files.first.name}', style: TextStyle(fontFamily: 'Cairo')),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => _uploadVideo(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEFAC52),
                  ),
                  child: const Text('حفظ الفيديو', style: TextStyle(fontFamily: 'Cairo')),
                ),
              ],
            )
                : ElevatedButton(
              onPressed: _pickFile,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEFAC52),
              ),
              child: const Text('اختار ملف فيديو', style: TextStyle(fontFamily: 'Cairo')),
            ),
          ],
        ),
      ),
    );
  }
}
