import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'ExamDetailsPage.dart';
import 'add_exam_page.dart'; // استيراد صفحة إضافة الامتحان
import 'package:google_fonts/google_fonts.dart';

class ExamsPage extends StatefulWidget {
  final String courseId;

  const ExamsPage({super.key, required this.courseId});

  @override
  _ExamsPageState createState() => _ExamsPageState();
}

class _ExamsPageState extends State<ExamsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('courses')
            .doc(widget.courseId)
            .collection('exams')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('لا توجد امتحانات.'));
          }

          final exams = snapshot.data!.docs;

          return ListView.builder(
            itemCount: exams.length,
            itemBuilder: (context, index) {
              final exam = exams[index];
              final examName = exam['name'];
              final examDuration = exam['duration'];

              return Card(
                margin: const EdgeInsets.all(8),
                color: const Color(0xFFEFAC52), // اللون الذهبي
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    examName,
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  subtitle: Text(
                    'المدة: $examDuration دقيقة',
                    style: GoogleFonts.cairo(
                      color: Colors.white70,
                    ),
                  ),
                  onTap: () {
                    // عند الضغط على الامتحان، انتقل إلى صفحة التفاصيل
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ExamDetailsPage(
                          examId: exam.id,
                          courseId: widget.courseId,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // فتح صفحة إضافة امتحان
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddExamPage(courseId: widget.courseId),
            ),
          );
        },
        backgroundColor: const Color(0xFF0096AB), // الأزرق الفاتح
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
