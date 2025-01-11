import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddQuestionsPage extends StatefulWidget {
  final String examId;
  final String courseId;

  const AddQuestionsPage({
    super.key,
    required this.examId,
    required this.courseId,
  });

  @override
  _AddQuestionsPageState createState() => _AddQuestionsPageState();
}

class _AddQuestionsPageState extends State<AddQuestionsPage> {
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _optionController = TextEditingController();
  String questionType = 'Multiple Choice';
  List<Map<String, dynamic>> options = [];
  String? trueFalseAnswer;
  bool isSaving = false;

  // Add options for Multiple Choice questions
  void _addOption() {
    final optionText = _optionController.text.trim();
    if (optionText.isEmpty) return;

    setState(() {
      options.add({
        'text': optionText,
        'isCorrect': false, // Default value is incorrect
      });
    });

    _optionController.clear();
  }

  // Save the question to Firestore
  void _saveQuestion() {
    final questionText = _questionController.text.trim();
    if (questionText.isEmpty) return;

    if (questionType == 'Multiple Choice' && options.isEmpty) return;
    if (questionType == 'Multiple Choice' && !options.any((option) => option['isCorrect'])) return;

    if (questionType == 'True/False' && trueFalseAnswer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select the correct answer for True/False!')),
      );
      return;
    }

    // Prepare data to be saved
    Map<String, dynamic> questionData = {
      'question': questionText,
      'type': questionType,
    };

    // Save options for Multiple Choice
    if (questionType == 'Multiple Choice') {
      questionData['options'] = options;
      questionData['correctAnswers'] = options
          .firstWhere((option) => option['isCorrect'], )?['text'];
    }

    // Save correct answer for True/False
    if (questionType == 'True/False') {
      questionData['correctAnswer'] = trueFalseAnswer; // Save the correct answer for True/False
    }

    // Save the question to Firestore
    FirebaseFirestore.instance
        .collection('courses')
        .doc(widget.courseId)
        .collection('exams')
        .doc(widget.examId)
        .collection('questions')
        .add(questionData)
        .then((_) {
      setState(() {
        options.clear();
        _questionController.clear();
        trueFalseAnswer = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Question saved!')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Questions',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF0096AB), // Blue color
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _questionController,
                decoration: InputDecoration(
                  labelText: 'Enter Question',
                  labelStyle: const TextStyle(color: Color(0xFF0096AB)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF1F1F1),
                ),
              ),
              const SizedBox(height: 20),
              DropdownButton<String>(
                value: questionType,
                onChanged: (String? newValue) {
                  setState(() {
                    questionType = newValue!;
                    options.clear();
                    trueFalseAnswer = null;
                  });
                },
                items: ['Multiple Choice', 'True/False']
                    .map<DropdownMenuItem<String>>((value) {
                  return DropdownMenuItem<String>(value: value, child: Text(value));
                }).toList(),
              ),
              const SizedBox(height: 20),
              if (questionType == 'Multiple Choice') ...[
                TextField(
                  controller: _optionController,
                  decoration: InputDecoration(
                    labelText: 'Enter Option',
                    labelStyle: const TextStyle(color: Color(0xFF0096AB)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF1F1F1),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _addOption,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0096AB),
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 10,
                    shadowColor: Colors.black.withOpacity(0.4),
                  ),
                  child: const Text(
                    'Add Option',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                ...options.map((option) {
                  return ListTile(
                    title: Text(option['text']),
                    leading: Checkbox(
                      value: option['isCorrect'],
                      onChanged: (bool? value) {
                        setState(() {
                          option['isCorrect'] = value!;
                        });
                      },
                    ),
                  );
                }).toList(),
              ],
              if (questionType == 'True/False') ...[
                RadioListTile<String>(
                  title: const Text('True'),
                  value: 'True',
                  groupValue: trueFalseAnswer,
                  onChanged: (String? value) {
                    setState(() {
                      trueFalseAnswer = value;
                    });
                  },
                ),
                RadioListTile<String>(
                  title: const Text('False'),
                  value: 'False',
                  groupValue: trueFalseAnswer,
                  onChanged: (String? value) {
                    setState(() {
                      trueFalseAnswer = value;
                    });
                  },
                ),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isSaving ? null : _saveQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0096AB),
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 10,
                  shadowColor: Colors.black.withOpacity(0.4),
                ),
                child: isSaving
                    ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                )
                    : const Text(
                  'Save Question',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
