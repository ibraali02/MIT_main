import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
  String studentName = '';
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

        List<Map<String, dynamic>> loadedQuestions = [];

        for (var questionDoc in questionsSnapshot.docs) {
          var questionData = questionDoc.data();
          var question = {
            'question': questionData['question'],
            'type': questionData['type'],
            'options': [],
            'correctAnswer': questionData['correctAnswers'],
          };

          var optionsSnapshot = questionData['options'];
          for (var optionData in optionsSnapshot) {
            question['options'].add({
              'text': optionData['text'],
              'isCorrect': optionData['isCorrect'],
            });
          }

          loadedQuestions.add(question);
        }

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
      if (answers[i] == questions[i]['correctAnswer'][0]) {
        correctAnswers++;
      }
    }
    setState(() {
      score = correctAnswers;
    });
  }

  void _submitExam() async {
    try {
      List<Map<String, dynamic>> studentAnswers = [];
      for (int i = 0; i < answers.length; i++) {
        studentAnswers.add({
          'questionNumber': i + 1,
          'answer': answers[i],
        });
      }

      var studentData = {
        'studentName': studentName,
        'answers': studentAnswers,
        'score': score,
        'timestamp': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.courseId)
          .collection('exams')
          .doc(widget.examId)
          .collection('student_answers')
          .add(studentData);

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إرسال الامتحان بنجاح!')));
    } catch (e) {
      print('Error saving student answers: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('حدث خطأ أثناء إرسال الامتحان.')));
    }
  }

  void _enterName(String name) {
    setState(() {
      studentName = name;
      hasEnteredName = true;
    });
    _loadQuestions();
  }

  @override
  Widget build(BuildContext context) {
    if (!hasEnteredName) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('أدخل اسمك'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'الرجاء إدخال اسمك لبدء الامتحان:',
                style: TextStyle(fontSize: 18),
              ),
              TextField(
                onChanged: (value) {
                  setState(() {
                    studentName = value;
                  });
                },
                decoration: const InputDecoration(hintText: 'أدخل اسمك'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: studentName.isNotEmpty ? () => _enterName(studentName) : null,
                child: const Text('ابدأ الامتحان'),
              ),
            ],
          ),
        ),
      );
    }

    if (questions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final currentQuestion = questions[currentQuestionIndex];
    final questionText = currentQuestion['question'] ?? '';
    final questionType = currentQuestion['type'] ?? '';
    final correctAnswers = currentQuestion['correctAnswer'];

    return Scaffold(
      appBar: AppBar(
        title: Text('الامتحان - $studentName'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'الوقت المتبقي: ${timerDuration.inMinutes}:${(timerDuration.inSeconds % 60).toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
            ),
            const SizedBox(height: 16),
            Text(
              'السؤال ${currentQuestionIndex + 1}: $questionText',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (questionType == 'Multiple Choice') ...[
              ...currentQuestion['options'].map<Widget>((option) {
                return RadioListTile<String>(
                  title: Text(option['text']),
                  value: option['text'],
                  groupValue: answers[currentQuestionIndex],
                  onChanged: (String? value) {
                    _onAnswerSelected(value!);
                  },
                );
              }).toList(),
            ] else if (questionType == 'True/False') ...[
              const Text('اختر الإجابة الصحيحة:'),
              RadioListTile<String>(
                title: const Text('صحيح'),
                value: 'True',
                groupValue: answers[currentQuestionIndex],
                onChanged: (String? value) {
                  _onAnswerSelected(value!);
                },
              ),
              RadioListTile<String>(
                title: const Text('خطأ'),
                value: 'False',
                groupValue: answers[currentQuestionIndex],
                onChanged: (String? value) {
                  _onAnswerSelected(value!);
                },
              ),
            ],
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: isFinished ? _submitExam : _nextQuestion,
              child: Text(isFinished ? 'تقديم الامتحان' : 'التالي'),
            ),
            if (isFinished)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'نتيجتك: $score / ${questions.length}',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'راجع إجاباتك:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...List.generate(questions.length, (index) {
                      final question = questions[index];
                      final userAnswer = answers[index];
                      final correctAnswer = question['correctAnswer'][0];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'سؤال ${index + 1}: ${question['question']}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text('إجابتك: $userAnswer'),
                            Text('الإجابة الصحيحة: $correctAnswer'),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
