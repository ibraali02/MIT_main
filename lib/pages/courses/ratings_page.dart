import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RatingsPage extends StatefulWidget {
  final String courseId;

  const RatingsPage({super.key, required this.courseId});

  @override
  _RatingsPageState createState() => _RatingsPageState();
}

class _RatingsPageState extends State<RatingsPage> {
  final TextEditingController commentController = TextEditingController();
  double contentScore = 3.0;
  double explanationScore = 3.0;
  double materialScore = 3.0;
  double overallScore = 3.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white), // السهم باللون الأبيض
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'أضف تقييم',
          style: TextStyle(color: Colors.white, fontSize: 20), // العنوان باللون الأبيض
        ),
        backgroundColor: const Color(0xFF0096AB), // اللون الأزرق
        elevation: 0, // إزالة الظل
      ),
      body: Directionality(
        textDirection: TextDirection.rtl, // الكتابة من اليمين لليسار
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'درجة المحتوى:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                _buildSlider(contentScore, (value) {
                  setState(() {
                    contentScore = value;
                  });
                }),
                const SizedBox(height: 20),
                const Text(
                  'درجة الشرح:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                _buildSlider(explanationScore, (value) {
                  setState(() {
                    explanationScore = value;
                  });
                }),
                const SizedBox(height: 20),
                const Text(
                  'درجة المواد:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                _buildSlider(materialScore, (value) {
                  setState(() {
                    materialScore = value;
                  });
                }),
                const SizedBox(height: 20),
                const Text(
                  'التقييم العام:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                _buildSlider(overallScore, (value) {
                  setState(() {
                    overallScore = value;
                  });
                }),
                const SizedBox(height: 20),
                _buildTextField(commentController, 'تعليقك'),
                const SizedBox(height: 20),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // دالة لإنشاء الـ Slider بشكل موحد
  Widget _buildSlider(double score, Function(double) onChanged) {
    return Slider(
      value: score,
      min: 1,
      max: 5,
      divisions: 4,
      label: score.toString(),
      onChanged: onChanged,
      activeColor: const Color(0xFF0096AB),
      inactiveColor: Colors.grey.shade400,
    );
  }

  // دالة لإنشاء حقل نصي بتصميم حديث
  Widget _buildTextField(TextEditingController controller, String label) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        ),
        maxLines: 4,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  // دالة لإنشاء زر الإرسال بتصميم أكبر وأجمل
  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: () => _saveRating(context),
      child: const Text(
        'إرسال التقييم',
        style: TextStyle(color: Colors.white, fontSize: 18), // زيادة حجم النص
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0096AB), // اللون الأزرق
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 30), // زيادة حجم الزر
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15), // حواف دائرية أكبر
        ),
        elevation: 8, // زيادة الظل
        shadowColor: Colors.black45,
        textStyle: const TextStyle(fontWeight: FontWeight.bold), // جعل النص ثقيلًا
      ),
    );
  }

  Future<void> _saveRating(BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.courseId)
          .collection('ratings')
          .add({
        'username': 'Anonymous',
        'contentScore': contentScore,
        'explanationScore': explanationScore,
        'materialScore': materialScore,
        'overallScore': overallScore,
        'comment': commentController.text,
        'createdAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إرسال التقييم بنجاح')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء حفظ التقييم: $e')),
      );
    }
  }
}
