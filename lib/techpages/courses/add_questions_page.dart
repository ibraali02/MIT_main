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

  // إضافة الخيارات لأسئلة الاختيارات المتعددة
  void _addOption() {
    final optionText = _optionController.text.trim();
    if (optionText.isEmpty) return;

    setState(() {
      options.add({
        'text': optionText,
        'isCorrect': false, // القيمة الافتراضية خاطئة
      });
    });

    _optionController.clear();
  }

  // حفظ السؤال في Firestore
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

    FirebaseFirestore.instance
        .collection('courses')
        .doc(widget.courseId)
        .collection('exams')
        .doc(widget.examId)
        .collection('questions')
        .add({
      'question': questionText,
      'type': questionType,
      'options': options,
      'correctAnswers': options.where((option) => option['isCorrect']).map((option) => option['text']).toList(),
    }).then((_) {
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
      appBar: AppBar(title: const Text('Add Questions')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _questionController,
              decoration: const InputDecoration(labelText: 'Enter Question'),
            ),
            DropdownButton<String>(
              value: questionType,
              onChanged: (String? newValue) {
                setState(() {
                  questionType = newValue!;
                  options.clear();
                  trueFalseAnswer = null;
                });
              },
              items: ['Multiple Choice', 'True/False', 'Essay']
                  .map<DropdownMenuItem<String>>((value) {
                return DropdownMenuItem<String>(value: value, child: Text(value));
              }).toList(),
            ),
            if (questionType == 'Multiple Choice') ...[
              TextField(
                controller: _optionController,
                decoration: const InputDecoration(labelText: 'Enter Option'),
              ),
              ElevatedButton(onPressed: _addOption, child: const Text('Add Option')),
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
            ElevatedButton(onPressed: _saveQuestion, child: const Text('Save Question')),
          ],
        ),
      ),
    );
  }
}
