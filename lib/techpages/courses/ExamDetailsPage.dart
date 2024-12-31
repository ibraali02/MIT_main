import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ExamDetailsPage extends StatelessWidget {
  final String examId;
  final String courseId;

  const ExamDetailsPage({super.key, required this.examId, required this.courseId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exam Details')),
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

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Exam: $examName', style: Theme.of(context).textTheme.titleLarge),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Duration: $examDuration minutes'),
              ),
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
                          margin: const EdgeInsets.all(8),
                          child: ListTile(
                            title: Text(questionText),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: options.map<Widget>((option) {
                                return Text(option['text']);
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
          );
        },
      ),
    );
  }
}
