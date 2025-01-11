import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'exam_page_logic.dart';

class ExamPage extends StatefulWidget {
  final String courseId;
  final String examId;

  const ExamPage({super.key, required this.courseId, required this.examId});

  @override
  _ExamPageState createState() => _ExamPageState();
}

class _ExamPageState extends State<ExamPage> {
  final ExamPageLogic _logic = ExamPageLogic();
  String studentFirstName = '';
  bool hasEnteredName = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!hasEnteredName) {
      _logic.loadQuestions(widget.courseId, widget.examId);
    }
  }

  // دالة لحفظ إجابات الطالب في Firestore
  Future<void> _saveExamResults() async {
    final examRef = FirebaseFirestore.instance.collection('exams').doc(widget.examId);
    final studentRef = examRef.collection('students').doc(studentFirstName);

    // حفظ البيانات داخل Firestore
    await studentRef.set({
      'studentName': studentFirstName,
      'answers': _logic.answers,
      'score': _logic.score,
      'questions': _logic.questions.map((q) => q['question']).toList(),
      'timeTaken': _logic.timerDuration.inSeconds,
      'timestamp': FieldValue.serverTimestamp(),
    });

    print('Exam results saved for $studentFirstName');
  }

  @override
  Widget build(BuildContext context) {
    if (!hasEnteredName) {
      return Scaffold(
        appBar: AppBar(
          title: Text('أدخل اسمك', style: GoogleFonts.cairo()),
          backgroundColor: Color(0xFF0096AB),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'الرجاء إدخال اسمك لبدء الامتحان:',
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0096AB),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                onChanged: (value) {
                  setState(() {
                    studentFirstName = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'أدخل اسمك',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Color(0xFF0096AB)),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  filled: true,
                  fillColor: Colors.blue[50],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: studentFirstName.isNotEmpty
                    ? () {
                  setState(() {
                    hasEnteredName = true;
                  });
                }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF0096AB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  elevation: 5,
                  shadowColor: Color(0xFF0096AB).withOpacity(0.3),
                ),
                child: Text(
                  'ابدأ الامتحان',
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_logic.questions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_logic.isFinished) {
      // بعد إتمام الامتحان، حفظ الإجابات في Firestore
      _saveExamResults();

      return Scaffold(
        appBar: AppBar(
          title: Text('النتيجة', style: GoogleFonts.cairo()),
          backgroundColor: Color(0xFF0096AB),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'نتيجتك: ${_logic.score} / ${_logic.questions.length}',
                style: GoogleFonts.cairo(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.builder(
                  itemCount: _logic.questions.length,
                  itemBuilder: (context, index) {
                    final question = _logic.questions[index]['question'];
                    final correctAnswer = _logic.questions[index]['type'] == 'True/False'
                        ? _logic.questions[index]['correctAnswer']
                        : _logic.questions[index]['correctAnswers'];
                    final userAnswer = _logic.answers[index] ?? 'لم يتم الإجابة';

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      color: Colors.blue[50],
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'السؤال ${index + 1}: $question',
                              style: GoogleFonts.cairo(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0096AB),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'الإجابة الصحيحة: $correctAnswer',
                              style: GoogleFonts.cairo(
                                fontSize: 14,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'إجابتك: $userAnswer',
                              style: GoogleFonts.cairo(
                                fontSize: 14,
                                color: userAnswer == correctAnswer
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF0096AB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  elevation: 5,
                  shadowColor: Color(0xFF0096AB).withOpacity(0.3),
                ),
                child: Text(
                  'العودة إلى الصفحة الرئيسية',
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final currentQuestion = _logic.questions[_logic.currentQuestionIndex];
    final questionText = currentQuestion['question'] ?? '';
    final questionType = currentQuestion['type'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text('الامتحان - $studentFirstName', style: GoogleFonts.cairo()),
        backgroundColor: Color(0xFF0096AB),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'الوقت المتبقي: ${_logic.timerDuration.inMinutes}:${(_logic.timerDuration.inSeconds % 60).toString().padLeft(2, '0')}',
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'السؤال ${_logic.currentQuestionIndex + 1}: $questionText',
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0096AB),
              ),
            ),
            const SizedBox(height: 16),
            if (questionType == 'Multiple Choice') ...[
              ...currentQuestion['options'].map<Widget>((option) {
                return RadioListTile<String>(
                  title: Text(option['text'], style: GoogleFonts.cairo()),
                  value: option['text'],
                  groupValue: _logic.answers[_logic.currentQuestionIndex],
                  onChanged: (String? value) {
                    _logic.onAnswerSelected(value!);
                    setState(() {});
                  },
                  activeColor: Color(0xFF0096AB),
                  tileColor: Colors.blue[50],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                );
              }).toList(),
            ] else if (questionType == 'True/False') ...[
              RadioListTile<String>(
                title: Text('صحيح', style: GoogleFonts.cairo()),
                value: 'True',
                groupValue: _logic.answers[_logic.currentQuestionIndex],
                onChanged: (String? value) {
                  _logic.onAnswerSelected(value!);
                  setState(() {});
                },
                activeColor: Color(0xFF0096AB),
                tileColor: Colors.blue[50],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              RadioListTile<String>(
                title: Text('خطأ', style: GoogleFonts.cairo()),
                value: 'False',
                groupValue: _logic.answers[_logic.currentQuestionIndex],
                onChanged: (String? value) {
                  _logic.onAnswerSelected(value!);
                  setState(() {});
                },
                activeColor: Color(0xFF0096AB),
                tileColor: Colors.blue[50],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ],
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _logic.currentQuestionIndex == _logic.questions.length - 1
                  ? () {
                setState(() {
                  _logic.isFinished = true;
                });
                _logic.calculateScore(setState);
              }
                  : () {
                setState(() {
                  _logic.nextQuestion(setState);
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF0096AB),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                elevation: 5,
                shadowColor: Color(0xFF0096AB).withOpacity(0.3),
              ),
              child: Text(
                _logic.currentQuestionIndex == _logic.questions.length - 1
                    ? 'إتمام الامتحان'
                    : 'السؤال التالي',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
