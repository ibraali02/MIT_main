import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'add_questions_page.dart'; // استيراد صفحة إضافة الأسئلة
import 'package:google_fonts/google_fonts.dart';

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
        const SnackBar(content: Text('يرجى تعبئة تفاصيل الامتحان.')),
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
        const SnackBar(content: Text('المدة غير صالحة')),
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
        SnackBar(content: Text('خطأ: $error')),
      );
      setState(() {
        isSaving = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'إضافة امتحان',
          style: GoogleFonts.cairo(
            fontSize: 24, // تحديد حجم الخط
            fontWeight: FontWeight.bold, // جعل الخط عريض
            color: Colors.white, // تحديد اللون الأبيض للنص
          ),
        ),
        backgroundColor: const Color(0xFF0096AB), // الأزرق الفاتح
        iconTheme: const IconThemeData(
          color: Colors.white, // تحديد اللون الأبيض لزر الرجوع
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Directionality(
          textDirection: TextDirection.rtl, // تحديد الاتجاه من اليمين لليسار
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // اسم الامتحان
              TextField(
                controller: _examController,
                decoration: InputDecoration(
                  labelText: 'اسم الامتحان',
                  labelStyle: GoogleFonts.cairo(color: Color(0xFF0096AB)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF1F1F1),
                ),
              ),
              const SizedBox(height: 20),

              // مدة الامتحان
              TextField(
                controller: _durationController,
                decoration: InputDecoration(
                  labelText: 'مدة الامتحان (بالدقائق)',
                  labelStyle: GoogleFonts.cairo(color: Color(0xFF0096AB)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF1F1F1),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 30),

              // زر حفظ الامتحان مع تكبير وتحسين الشكل
              ElevatedButton(
                onPressed: isSaving ? null : _saveExam,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0096AB), // اللون الأزرق
                  padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  textStyle: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold),
                  elevation: 5, // إضافة الظل
                ),
                child: isSaving
                    ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                )
                    : Text(
                  'حفظ الامتحان',
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // لون الخط الأبيض
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
