import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ExamDetailsPage extends StatelessWidget {
  final String examId;
  final String courseId;

  const ExamDetailsPage({super.key, required this.examId, required this.courseId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Details'),
        backgroundColor: const Color(0xFF0096AB), // اللون الأزرق
        foregroundColor: Colors.white, // تغيير لون النص في الـ AppBar إلى اللون الأبيض
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('courses')
            .doc(courseId)
            .collection('exams')
            .doc(examId)
            .get(),
        builder: (context, examSnapshot) {
          if (examSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!examSnapshot.hasData || !examSnapshot.data!.exists) {
            return const Center(child: Text('No exam details found.'));
          }

          final examData = examSnapshot.data!;
          final examName = examData['name'];
          final examDuration = examData['duration'];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // عرض اسم الامتحان
                Text(
                  'Exam: $examName',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: const Color(0xFF0096AB), // اللون الأزرق للعناوين
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 8),
                // عرض مدة الامتحان
                Text(
                  'Duration: $examDuration minutes',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87, // لون الخط الأسود
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(),

                // عرض الأسئلة
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('courses')
                        .doc(courseId)
                        .collection('exams')
                        .doc(examId)
                        .collection('questions')
                        .snapshots(),
                    builder: (context, questionsSnapshot) {
                      if (questionsSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!questionsSnapshot.hasData || questionsSnapshot.data!.docs.isEmpty) {
                        return const Center(child: Text('No questions found.'));
                      }

                      final questions = questionsSnapshot.data!.docs;

                      return ListView.builder(
                        itemCount: questions.length,
                        itemBuilder: (context, index) {
                          final question = questions[index];
                          final questionText = question['question'];
                          final options = question['options'];

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              title: Text(
                                questionText,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black87, // اللون الأسود للعناوين
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: options.map<Widget>((option) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: Text(
                                      option['text'],
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black54, // لون خط الخيارات
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
