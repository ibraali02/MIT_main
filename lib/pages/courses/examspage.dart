import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'ExamPage.dart';

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

          var exams = snapshot.data!.docs;

          return ListView.builder(
            itemCount: exams.length,
            itemBuilder: (context, index) {
              var exam = exams[index];
              var examName = exam['name'];
              var examDuration = exam['duration'];

              // استعلام للحصول على عدد الأسئلة من مجموعة "questions" داخل الامتحان
              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('courses')
                    .doc(widget.courseId)
                    .collection('exams')
                    .doc(exam.id)
                    .collection('questions')
                    .snapshots(),
                builder: (context, questionSnapshot) {
                  if (questionSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  var questionCount = questionSnapshot.data?.docs.length ?? 0;

                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Text(examName),
                      subtitle: Text('Duration: $examDuration minutes\nQuestions: $questionCount'),
                      trailing: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ExamPage(
                                courseId: widget.courseId,
                                examId: exam.id,
                              ),
                            ),
                          );
                        },
                        child: const Text('Start Exam'),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
