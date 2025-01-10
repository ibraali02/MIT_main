import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ExamDetailsPage extends StatelessWidget {
  final String examId;
  final String courseId;

  const ExamDetailsPage({super.key, required this.examId, required this.courseId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'تفاصيل الامتحان',
          style: GoogleFonts.cairo(),
        ),
        backgroundColor: const Color(0xFF0096AB),
        foregroundColor: Colors.white,
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
            return const Center(child: Text('لم يتم العثور على تفاصيل الامتحان.'));
          }

          final examData = examSnapshot.data!;
          final examName = examData['name'];
          final examDuration = examData['duration'];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الامتحان: $examName',
                  style: GoogleFonts.cairo(
                    color: const Color(0xFF0096AB),
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'المدة: $examDuration دقيقة',
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(),

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
                        return const Center(child: Text('لا توجد أسئلة.'));
                      }

                      final questions = questionsSnapshot.data!.docs;

                      return ListView.builder(
                        itemCount: questions.length,
                        itemBuilder: (context, index) {
                          final question = questions[index];
                          final questionText = question['question'];
                          final questionType = question['type']; // نوع السؤال
                          final correctAnswer = question['correctAnswer']; // الجواب الصحيح

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              title: Text(
                                questionText,
                                style: GoogleFonts.cairo(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                              subtitle: questionType == 'True/False'
                                  ? Text(
                                'الإجابة الصحيحة: $correctAnswer',
                                style: GoogleFonts.cairo(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ) // عرض الجواب الصحيح
                                  : (question['options'] != null && question['options'].isNotEmpty
                                  ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: question['options'].map<Widget>((option) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: Text(
                                      option['text'],
                                      style: GoogleFonts.cairo(
                                        fontSize: 14,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              )
                                  : null), // لا تعرض شيئًا إذا لم يكن هناك خيارات
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