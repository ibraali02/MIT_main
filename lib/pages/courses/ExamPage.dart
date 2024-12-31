import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ExamPage extends StatefulWidget {
  final String courseId; // ID of the course
  final String examId; // ID of the exam

  const ExamPage({super.key, required this.courseId, required this.examId});

  @override
  _ExamPageState createState() => _ExamPageState();
}

class _ExamPageState extends State<ExamPage> {
  int currentQuestionIndex = 0;
  List<Map<String, dynamic>> questions = [];
  List<String?> answers = []; // Store answers for each question
  bool isFinished = false; // Flag to determine if exam is finished
  int score = 0; // Store the student's score
  int remainingTime = 0; // Remaining time in seconds
  late int initialTime; // Initial duration of the exam
  late Duration timerDuration; // Timer duration
  String studentName = ''; // To store the student's name
  bool hasEnteredName = false; // Flag to track if the student has entered their name

  @override
  void initState() {
    super.initState();
  }

  // Function to load questions from Firestore
  void _loadQuestions() async {
    try {
      var examSnapshot = await FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.courseId)
          .collection('exams')
          .doc(widget.examId)
          .get(); // Get the exam document

      if (examSnapshot.exists && examSnapshot.data() != null) {
        initialTime = examSnapshot['duration']; // Get the duration from Firestore (in minutes)
        remainingTime = initialTime * 60; // Convert to seconds
        timerDuration = Duration(seconds: remainingTime);

        var questionsSnapshot = await FirebaseFirestore.instance
            .collection('courses')
            .doc(widget.courseId)
            .collection('exams')
            .doc(widget.examId)
            .collection('questions')
            .get(); // Get the questions collection

        List<Map<String, dynamic>> loadedQuestions = [];

        for (var questionDoc in questionsSnapshot.docs) {
          var questionData = questionDoc.data();
          var question = {
            'question': questionData['question'],
            'type': questionData['type'],
            'options': [],
            'correctAnswer': questionData['correctAnswers'],
          };

          // Load options
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
          answers = List.generate(loadedQuestions.length, (index) => null); // Initialize answers list
        });

        _startTimer(); // Start the timer once questions are loaded
      }
    } catch (error) {
      print('Error loading exam or questions: $error');
    }
  }

  // Start the timer
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

  // Handle answer selection
  void _onAnswerSelected(String answer) {
    setState(() {
      answers[currentQuestionIndex] = answer;
    });
  }

  // Navigate to the next question
  void _nextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
    } else {
      setState(() {
        isFinished = true;
        _calculateScore(); // Calculate score after finishing the exam
      });
    }
  }

  // Calculate score
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

  // Submit the exam and save data to Firestore
  void _submitExam() async {
    // Save student answers to Firestore
    try {
      // Create a list of question number and the answer selected by the student
      List<Map<String, dynamic>> studentAnswers = [];
      for (int i = 0; i < answers.length; i++) {
        studentAnswers.add({
          'questionNumber': i + 1, // Store question number (1-based index)
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
          .collection('student_answers') // Create a collection for storing student answers
          .add(studentData);

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Exam submitted successfully!')));
    } catch (e) {
      print('Error saving student answers: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error submitting exam.')));
    }
  }

  // Handle student name input
  void _enterName(String name) {
    setState(() {
      studentName = name;
      hasEnteredName = true;
    });
    _loadQuestions(); // Load questions after entering name
  }

  @override
  Widget build(BuildContext context) {
    // If the student hasn't entered their name, show the name input form
    if (!hasEnteredName) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Enter Your Name'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Please enter your name to begin the exam:',
                style: TextStyle(fontSize: 18),
              ),
              TextField(
                onChanged: (value) {
                  setState(() {
                    studentName = value;
                  });
                },
                decoration: const InputDecoration(hintText: 'Enter your name'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: studentName.isNotEmpty ? () => _enterName(studentName) : null,
                child: const Text('Start Exam'),
              ),
            ],
          ),
        ),
      );
    }

    // Once the questions are loaded, display the exam
    if (questions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final currentQuestion = questions[currentQuestionIndex];
    final questionText = currentQuestion['question'] ?? '';
    final questionType = currentQuestion['type'] ?? '';
    final correctAnswers = currentQuestion['correctAnswer'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Exam - $studentName'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timer display
            Text(
              'Time Remaining: ${timerDuration.inMinutes}:${(timerDuration.inSeconds % 60).toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
            ),
            const SizedBox(height: 16),

            // Question text
            Text(
              'Question ${currentQuestionIndex + 1}: $questionText',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Display options or answer choices based on question type
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
              const Text('Select the correct answer:'),
              RadioListTile<String>(
                title: const Text('True'),
                value: 'True',
                groupValue: answers[currentQuestionIndex],
                onChanged: (String? value) {
                  _onAnswerSelected(value!);
                },
              ),
              RadioListTile<String>(
                title: const Text('False'),
                value: 'False',
                groupValue: answers[currentQuestionIndex],
                onChanged: (String? value) {
                  _onAnswerSelected(value!);
                },
              ),
            ],

            const SizedBox(height: 16),

            // Next Button
            ElevatedButton(
              onPressed: isFinished ? _submitExam : _nextQuestion,
              child: Text(isFinished ? 'Submit Exam' : 'Next'),
            ),

            // Display score only after finishing the exam
            if (isFinished)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Score: $score / ${questions.length}',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Review Your Answers:',
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
                              'Q${index + 1}: ${question['question']}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text('Your Answer: $userAnswer'),
                            Text('Correct Answer: $correctAnswer'),
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
