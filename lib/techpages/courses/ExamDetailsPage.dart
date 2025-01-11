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
      body: SingleChildScrollView(
        child: FutureBuilder<DocumentSnapshot>(
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
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'المدة: $examDuration دقيقة',
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),

                  // StreamBuilder for exam questions with answers
                  FutureBuilder<QuerySnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('courses')
                        .doc(courseId)
                        .collection('exams')
                        .doc(examId)
                        .collection('questions')
                        .get(),
                    builder: (context, questionsSnapshot) {
                      if (questionsSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!questionsSnapshot.hasData || questionsSnapshot.data!.docs.isEmpty) {
                        return const Center(child: Text('لا توجد أسئلة.'));
                      }

                      final questions = questionsSnapshot.data!.docs;

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'الأسئلة مع الإجابات:',
                                style: GoogleFonts.cairo(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...questions.map((question) {
                                final questionText = question['question'];
                                final questionType = question['type'];

                                // Handling multiple choice questions
                                if (questionType == 'Multiple Choice') {
                                  final options = List<Map<String, dynamic>>.from(question['options']);
                                  final correctAnswer = options.firstWhere((option) => option['isCorrect'] == true)['text'];

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'السؤال: $questionText',
                                          style: GoogleFonts.cairo(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        ...options.map((option) {
                                          return Padding(
                                            padding: const EdgeInsets.only(bottom: 8.0),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  option['isCorrect'] == true
                                                      ? Icons.check_circle
                                                      : Icons.radio_button_unchecked,
                                                  color: option['isCorrect'] == true
                                                      ? Colors.green
                                                      : Colors.grey,
                                                  size: 20,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  option['text'],
                                                  style: GoogleFonts.cairo(
                                                    fontSize: 16,
                                                    color: Colors.black54,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                        const SizedBox(height: 8),
                                        Text(
                                          'الإجابة الصحيحة: $correctAnswer',
                                          style: GoogleFonts.cairo(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                                // Handling True/False questions
                                else if (questionType == 'True/False') {
                                  final correctAnswer = question['correctAnswer'];

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'السؤال: $questionText',
                                          style: GoogleFonts.cairo(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Icon(
                                              correctAnswer == 'True'
                                                  ? Icons.check_circle
                                                  : Icons.radio_button_unchecked,
                                              color: correctAnswer == 'True'
                                                  ? Colors.green
                                                  : Colors.grey,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'الإجابة الصحيحة: $correctAnswer',
                                              style: GoogleFonts.cairo(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                }

                                return SizedBox.shrink();
                              }).toList(),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),
                  const Divider(),

                  // StreamBuilder for student answers
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('courses')
                        .doc(courseId)
                        .collection('exams')
                        .doc(examId)
                        .collection('student_answers')
                        .snapshots(),
                    builder: (context, answersSnapshot) {
                      if (answersSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!answersSnapshot.hasData || answersSnapshot.data!.docs.isEmpty) {
                        return const Center(child: Text('لا توجد إجابات.'));
                      }

                      final studentAnswers = answersSnapshot.data!.docs;

                      return ListView.builder(
                        shrinkWrap: true, // Important to use shrinkWrap
                        physics: NeverScrollableScrollPhysics(), // Prevents scrolling within the ListView
                        itemCount: studentAnswers.length,
                        itemBuilder: (context, index) {
                          final studentAnswer = studentAnswers[index];
                          final studentName = studentAnswer['studentName'];
                          final answers = studentAnswer['answers'] as List<dynamic>;

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'الطالب: $studentName',
                                    style: GoogleFonts.cairo(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ...answers.map((answer) {
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 8.0),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'السؤال: ${answer['question']}',
                                              style: GoogleFonts.cairo(
                                                fontSize: 16,
                                                color: Colors.black54,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'الإجابة: ${answer['answer']}',
                                            style: GoogleFonts.cairo(
                                              fontSize: 16,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
