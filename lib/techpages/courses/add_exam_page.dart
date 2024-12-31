import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'add_questions_page.dart'; // استيراد صفحة إضافة الأسئلة

class AddExamPage extends StatefulWidget {
  final String courseId;

  const AddExamPage({super.key, required this.courseId});

  @override
  _AddExamPageState createState() => _AddExamPageState();
}

class _AddExamPageState extends State<AddExamPage> {
  final TextEditingController _examController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  bool isSaving = false;

  String? examName;
  int? examDuration;

  // حفظ الامتحان ثم الانتقال إلى صفحة الأسئلة
  void _saveExam() {
    if (_examController.text.isEmpty || _durationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in exam details.')),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    examName = _examController.text.trim();
    examDuration = int.tryParse(_durationController.text);

    if (examDuration == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid duration')),
      );
      setState(() {
        isSaving = false;
      });
      return;
    }

    // حفظ بيانات الامتحان
    FirebaseFirestore.instance
        .collection('courses')
        .doc(widget.courseId)
        .collection('exams')
        .add({
      'name': examName,
      'duration': examDuration,
    }).then((examDocRef) {
      setState(() {
        isSaving = false;
      });

      // الانتقال إلى صفحة إضافة الأسئلة
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddQuestionsPage(
            examId: examDocRef.id,
            courseId: widget.courseId,
          ),
        ),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
      setState(() {
        isSaving = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Exam')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _examController,
              decoration: const InputDecoration(labelText: 'Exam Name'),
            ),
            TextField(
              controller: _durationController,
              decoration: const InputDecoration(labelText: 'Exam Duration (minutes)'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isSaving ? null : _saveExam,
              child: isSaving
                  ? const CircularProgressIndicator()
                  : const Text('Save Exam'),
            ),
          ],
        ),
      ),
    );
  }
}
