import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
  String questionType = 'اختيار من متعدد';
  List<Map<String, dynamic>> options = [];
  String? trueFalseAnswer;
  bool isSaving = false;

  void _addOption() {
    final optionText = _optionController.text.trim();
    if (optionText.isEmpty) return;

    setState(() {
      options.add({
        'text': optionText,
        'isCorrect': false,
      });
    });

    _optionController.clear();
  }

  void _saveQuestion() {
    final questionText = _questionController.text.trim();
    if (questionText.isEmpty) return;

    if (questionType == 'اختيار من متعدد' && options.isEmpty) return;
    if (questionType == 'اختيار من متعدد' && !options.any((option) => option['isCorrect'])) return;

    if (questionType == 'صح/خطأ' && trueFalseAnswer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار الإجابة الصحيحة لصحيح/خطأ!')),
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
        const SnackBar(content: Text('تم حفظ السؤال!')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: $error')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'إضافة أسئلة',
          style: GoogleFonts.cairo(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF0096AB),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _questionController,
                  decoration: InputDecoration(
                    labelText: 'أدخل السؤال',
                    labelStyle: TextStyle(color: const Color(0xFF0096AB)),
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
                  items: ['اختيار من متعدد', 'صح/خطأ', 'مقال']
                      .map<DropdownMenuItem<String>>((value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                if (questionType == 'اختيار من متعدد') ...[
                  TextField(
                    controller: _optionController,
                    decoration: InputDecoration(
                      labelText: 'أدخل الخيار',
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
                    child: Text(
                      'إضافة خيار',
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

                if (questionType == 'صح/خطأ') ...[
                  RadioListTile<String>(
                    title: const Text('صح'),
                    value: 'True',
                    groupValue: trueFalseAnswer,
                    onChanged: (String? value) {
                      setState(() {
                        trueFalseAnswer = value;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('خطأ'),
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
                      : Text(
                    'حفظ السؤال',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
