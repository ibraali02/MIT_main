import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';

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
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'الفيديوهات',
          style: GoogleFonts.cairo(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UploadVideoPage(courseId: widget.courseId),
                ),
              );
            },
            color: const Color(0xFF0096AB),
          ),
        ],
        elevation: 0.0,
      ),
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
            return const Center(child: Text('لا توجد فيديوهات.'));
          }

          final videos = snapshot.data!.docs;

          return ListView.builder(
            itemCount: videos.length,
            itemBuilder: (context, index) {
              final video = videos[index];
              final videoName = video['videoName'];
              final description = video['description'];
              final fileUrl = video['fileUrl'];
              final videoId = video.id;

              return Card(
                margin: const EdgeInsets.all(8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                elevation: 5,
                color: const Color(0xFFF2F2F2),
                child: ListTile(
                  title: Text(
                    videoName,
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0096AB),
                    ),
                  ),
                  subtitle: Text(
                    description,
                    style: GoogleFonts.cairo(
                      color: const Color(0xFF4F4F4F),
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.play_circle_fill),
                        color: const Color(0xFF0096AB),
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
                      IconButton(
                        icon: const Icon(Icons.delete),
                        color: Colors.red,
                        onPressed: () async {
                          try {
                            await FirebaseFirestore.instance
                                .collection('courses')
                                .doc(widget.courseId)
                                .collection('videos')
                                .doc(videoId)
                                .delete();

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('تم حذف الفيديو بنجاح')),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('خطأ في حذف الفيديو: $e')),
                            );
                          }
                        },
                      ),
                    ],
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
          const SnackBar(content: Text('لم يتم اختيار الملف')),
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
        const SnackBar(content: Text('لم يتم اختيار الملف')),
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
        title: Text(
          'رفع الفيديو',
          style: GoogleFonts.cairo(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: videoNameController,
              decoration: InputDecoration(
                labelText: 'اسم الفيديو',
                labelStyle: GoogleFonts.cairo(
                  color: const Color(0xFF0096AB),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: const Color(0xFF0096AB)),
                ),
              ),
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'الوصف',
                labelStyle: GoogleFonts.cairo(
                  color: const Color(0xFF0096AB),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: const Color(0xFF0096AB)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _selectedFile != null
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الملف المحدد: ${_selectedFile!.files.first.name}',
                  style: GoogleFonts.cairo(
                    color: const Color(0xFF0096AB),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => _uploadVideo(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0096AB),
                  ),
                  child: const Text('حفظ الفيديو'),
                ),
              ],
            )
                : ElevatedButton(
              onPressed: _pickFile,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0096AB),
              ),
              child: const Text(
                'اختيار ملف فيديو',
                style: TextStyle(color: Colors.white),  // Set text color to white
              ),            ),
          ],
        ),
      ),
    );
  }
}
