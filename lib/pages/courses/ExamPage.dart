import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ExamPage extends StatefulWidget {
  final String courseId;
  final String examId;

  const ExamPage({super.key, required this.courseId, required this.examId});

  @override
  _ExamPageState createState() => _ExamPageState();
}

class _ExamPageState extends State<ExamPage> {
  int currentQuestionIndex = 0;
  List<Map<String, dynamic>> questions = [];
  List<String?> answers = [];
  bool isFinished = false;
  int score = 0;
  int remainingTime = 0;
  late int initialTime;
  late Duration timerDuration;
  String studentFirstName = '';
  bool hasEnteredName = false;

  @override
  void initState() {
    super.initState();
  }

  void _loadQuestions() async {
    try {
      var examSnapshot = await FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.courseId)
          .collection('exams')
          .doc(widget.examId)
          .get();

      if (examSnapshot.exists && examSnapshot.data() != null) {
        initialTime = examSnapshot['duration'];
        remainingTime = initialTime * 60;
        timerDuration = Duration(seconds: remainingTime);

        var questionsSnapshot = await FirebaseFirestore.instance
            .collection('courses')
            .doc(widget.courseId)
            .collection('exams')
            .doc(widget.examId)
            .collection('questions')
            .get();

        List<Map<String, dynamic>> loadedQuestions = questionsSnapshot.docs.map((questionDoc) {
          var questionData = questionDoc.data();
          return {
            'question': questionData['question'],
            'type': questionData['type'],
            'options': questionData['options'],
            'correctAnswer': questionData['correctAnswer'],
            'correctAnswers': questionData['correctAnswers'],
          };
        }).toList();

        setState(() {
          questions = loadedQuestions;
          answers = List.generate(loadedQuestions.length, (index) => null);
        });

        _startTimer();
      }
    } catch (error) {
      print('Error loading exam or questions: $error');
    }
  }

  void _startTimer() {
    if (remainingTime > 0) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted && remainingTime > 0 && !isFinished) {
          setState(() {
            remainingTime--;
            timerDuration = Duration(seconds: remainingTime);
          });
          _startTimer();
        }
      });
    }
  }

  void _onAnswerSelected(String answer) {
    setState(() {
      answers[currentQuestionIndex] = answer;
    });
  }

  void _nextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
    } else {
      setState(() {
        isFinished = true;
        _calculateScore();
      });
    }
  }

  void _calculateScore() {
    int correctAnswers = 0;
    for (int i = 0; i < questions.length; i++) {
      if (questions[i]['type'] == 'True/False') {
        if (answers[i] != null && answers[i] == questions[i]['correctAnswer']) {
          correctAnswers++;
        }
      } else {
        if (answers[i] != null &&
            questions[i]['correctAnswers'].contains(answers[i])) {
          correctAnswers++;
        }
      }
    }
    setState(() {
      score = correctAnswers;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!hasEnteredName) {
      return Scaffold(
        appBar: AppBar(
          title: Text('أدخل اسمك', style: GoogleFonts.cairo()), // تغيير الخط
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
                  _loadQuestions();
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

    if (questions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (isFinished) {
      return Scaffold(
        appBar: AppBar(
          title: Text('النتيجة', style: GoogleFonts.cairo()), // تغيير الخط
          backgroundColor: Color(0xFF0096AB),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'نتيجتك: $score / ${questions.length}',
                style: GoogleFonts.cairo(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.builder(
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    final question = questions[index]['question'];
                    final correctAnswer = questions[index]['type'] == 'True/False'
                        ? questions[index]['correctAnswer']
                        : questions[index]['correctAnswers'].join(', ');
                    final userAnswer = answers[index] ?? 'لم يتم الإجابة';

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

    final currentQuestion = questions[currentQuestionIndex];
    final questionText = currentQuestion['question'] ?? '';
    final questionType = currentQuestion['type'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text('الامتحان - $studentFirstName', style: GoogleFonts.cairo()), // تغيير الخط
        backgroundColor: Color(0xFF0096AB),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'الوقت المتبقي: ${timerDuration.inMinutes}:${(timerDuration.inSeconds % 60).toString().padLeft(2, '0')}',
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'السؤال ${currentQuestionIndex + 1}: $questionText',
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
                  groupValue: answers[currentQuestionIndex],
                  onChanged: (String? value) {
                    _onAnswerSelected(value!);
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
                groupValue: answers[currentQuestionIndex],
                onChanged: (String? value) {
                  _onAnswerSelected(value!);
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
                groupValue: answers[currentQuestionIndex],
                onChanged: (String? value) {
                  _onAnswerSelected(value!);
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
              onPressed: currentQuestionIndex == questions.length - 1
                  ? () {
                setState(() {
                  isFinished = true;
                  _calculateScore();
                });
              }
                  : _nextQuestion,
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
                currentQuestionIndex == questions.length - 1
                    ? 'عرض النتيجة'
                    : 'التالي',
                style: GoogleFonts.cairo(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
