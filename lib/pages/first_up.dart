import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // للتعامل مع Firestore
import 'learning_reminders_page.dart'; // تأكد من صحة المسار

class FirstUpPage extends StatefulWidget {
  const FirstUpPage({super.key});

  @override
  _FirstUpPageState createState() => _FirstUpPageState();
}

class _FirstUpPageState extends State<FirstUpPage> {
  String selectedClass = '';

  @override
  void initState() {
    super.initState();
    // جلب الـ user_document_id عند بدء الصفحة
    _getUserDocumentId();
  }

  Future<void> _getUserDocumentId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userDocumentId = prefs.getString('user_document_id');
    if (userDocumentId != null) {
      print('User Document ID: $userDocumentId');
      // هنا يمكنك تخزين الـ user_document_id مع الفصل في Firestore
      await _storeSelectedClassInFirestore(userDocumentId);
    }
  }

  Future<void> _storeSelectedClassInFirestore(String userDocumentId) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // تخزين الـ user_document_id مع الفصل في Firestore
    try {
      await firestore.collection('users').doc(userDocumentId).set({
        'selected_class': selectedClass,
      }, SetOptions(merge: true)); // دمج البيانات مع البيانات الموجودة بالفعل
      print('Class stored successfully in Firestore.');
    } catch (e) {
      print('Error storing class in Firestore: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'اختر فصلك الدراسي',
            style: GoogleFonts.cairo(
              fontSize: 24,
              fontWeight: FontWeight.bold, // جعل الخط عريض
              color: Colors.lightBlue, // لون الخط أبيض
            ),
            textAlign: TextAlign.center, // وضع النص في المنتصف
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              ClassOption(
                text: 'من الفصل الأول إلى الرابع',
                imagePath: 'lib/images/age2.png', // الصور كما هي دون تغيير
                height: 300,
                isSelected: selectedClass == 'من الفصل الأول إلى الرابع',
                onTap: () {
                  setState(() {
                    selectedClass = 'من الفصل الأول إلى الرابع';
                  });
                },
              ),
              const SizedBox(width: 20),
              ClassOption(
                text: 'فوق الفصل الرابع',
                imagePath: 'lib/images/age2.png', // الصور كما هي دون تغيير
                height: 400,
                isSelected: selectedClass == 'فوق الفصل الرابع',
                onTap: () {
                  setState(() {
                    selectedClass = 'فوق الفصل الرابع';
                  });
                },
              ),
              const SizedBox(width: 20),
              ClassOption(
                text: 'خريج',
                imagePath: 'lib/images/age3.png', // الصور كما هي دون تغيير
                height: 500,
                isSelected: selectedClass == 'خريج',
                onTap: () {
                  setState(() {
                    selectedClass = 'خريج';
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              ElevatedButton(
                onPressed: () {
                  // منطق التخطي
                },
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  backgroundColor: Colors.grey,
                  padding: const EdgeInsets.all(20),
                ),
                child: Directionality(
                  textDirection: TextDirection.rtl, // ضبط اتجاه النص إلى RTL
                  child: Text(
                    'تخطي',
                    style: GoogleFonts.cairo(color: Colors.white),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LearningRemindersPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.all(35),
                  textStyle: const TextStyle(fontSize: 20),
                ),
                child: Directionality(
                  textDirection: TextDirection.rtl, // ضبط اتجاه النص إلى RTL
                  child: Text(
                    'استمرار',
                    style: GoogleFonts.cairo(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ClassOption extends StatelessWidget {
  final String text;
  final String imagePath;
  final double height;
  final bool isSelected;
  final VoidCallback onTap;

  const ClassOption({super.key,
    required this.text,
    required this.imagePath,
    required this.height,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color(0xFFE0A800),
        ),
        child: Column(
          children: <Widget>[
            Container(
              height: height * 0.1,
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    imagePath,
                    height: height * 0.4,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    text,
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      color: Colors.white, // جعل اللون أبيض
                      fontWeight: FontWeight.bold, // جعل الخط عريض
                    ),
                    textAlign: TextAlign.center, // وضع النص في المنتصف
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
