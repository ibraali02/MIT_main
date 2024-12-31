import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'ExamDetailsPage.dart';
import 'add_exam_page.dart'; // استيراد صفحة إضافة الامتحان

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
      appBar: AppBar(title: const Text('Exams')),
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
            return const Center(child: Text('No exams available.'));
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
                child: ListTile(
                  title: Text(examName),
                  subtitle: Text('Duration: $examDuration minutes'),
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
        child: const Icon(Icons.add),
      ),
    );
  }
}
