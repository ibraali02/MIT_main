// exam_page_logic.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ExamPageLogic {
  int currentQuestionIndex = 0;
  List<Map<String, dynamic>> questions = [];
  List<String?> answers = [];
  bool isFinished = false;
  int score = 0;
  int remainingTime = 0;
  late int initialTime;
  late Duration timerDuration;

  // Load questions and setup timer
  Future<void> loadQuestions(String courseId, String examId) async {
    try {
      var examSnapshot = await FirebaseFirestore.instance
          .collection('courses')
          .doc(courseId)
          .collection('exams')
          .doc(examId)
          .get();

      if (examSnapshot.exists && examSnapshot.data() != null) {
        initialTime = examSnapshot['duration'];
        remainingTime = initialTime * 60;
        timerDuration = Duration(seconds: remainingTime);

        var questionsSnapshot = await FirebaseFirestore.instance
            .collection('courses')
            .doc(courseId)
            .collection('exams')
            .doc(examId)
            .collection('questions')
            .get();

        List<Map<String, dynamic>> loadedQuestions = questionsSnapshot.docs.map((questionDoc) {
          var questionData = questionDoc.data();
          return {
            'question': questionData['question'],
            'type': questionData['type'],
            'options': questionData['type'] == 'True/False' ? [] : questionData['options'],
            'correctAnswer': questionData['type'] == 'True/False'
                ? (questionData['correctAnswer'] == 'true')
                : null,
            'correctAnswers': questionData['type'] != 'True/False'
                ? questionData['correctAnswers']
                : null,
          };
        }).toList();

        questions = loadedQuestions;
        answers = List.generate(loadedQuestions.length, (index) => null);
      }
    } catch (error) {
      print('Error loading exam or questions: $error');
    }
  }

  // Timer logic
  void startTimer(Function setState, Function onTimeUpdate) {
    if (remainingTime > 0) {
      Future.delayed(const Duration(seconds: 1), () {
        if (remainingTime > 0 && !isFinished) {
          setState(() {
            remainingTime--;
            timerDuration = Duration(seconds: remainingTime);
          });
          onTimeUpdate();
        }
      });
    }
  }

  // Answer selection
  void onAnswerSelected(String answer) {
    answers[currentQuestionIndex] = answer;
  }

  // Proceed to next question
  void nextQuestion(Function setState) {
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
    } else {
      setState(() {
        isFinished = true;
      });
    }
  }

  // Calculate score
  void calculateScore(Function setState) {
    int correctAnswers = 0;
    for (int i = 0; i < questions.length; i++) {
      if (questions[i]['type'] == 'True/False') {
        if (answers[i] != null && answers[i] == questions[i]['correctAnswer']) {
          correctAnswers++;
        }
      } else {
        if (answers[i] != null &&
            questions[i]['correctAnswers'] == answers[i]) {
          correctAnswers++;
        }
      }
    }
    setState(() {
      score = correctAnswers;
    });
  }
}
