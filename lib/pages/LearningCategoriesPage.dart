import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // For Cairo font
import 'package:cloud_firestore/cloud_firestore.dart'; // For Firestore
import 'dart:math';
import 'navigation_page.dart';

class TechCategoriesPage extends StatefulWidget {
  const TechCategoriesPage({super.key});

  @override
  _TechCategoriesPageState createState() => _TechCategoriesPageState();
}

class _TechCategoriesPageState extends State<TechCategoriesPage> {
  int selectedIndex = -1;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to store selected category in Firestore
  void _storeSelectedCategory(String label) {
    _firestore.collection('selectedCategories').add({
      'category': label,
      'timestamp': FieldValue.serverTimestamp(),
    }).then((value) {
      print('Category stored successfully');
    }).catchError((error) {
      print('Error storing category: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''), // إخفاء العنوان في الـ AppBar
      ),
      body: Container(
        color: Colors.white,
        child: Stack(
          children: [
            // السؤال فوق الدوائر
            const Positioned(
              top: 50,
              left: 10,
              child: Text(
                'ماذا تريد أن تتعلم؟', // السؤال باللغة العربية
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            // دائرة واحدة في المنتصف
            _buildTechCircle('البرمجة', 150, 300, 0),
            // توزيع الدوائر الأخرى حول المركز
            ...List.generate(6, (index) {
              double angle = (2 * pi / 6) * index;
              double radius = 150;
              double centerX = 155;
              double centerY = 300;

              double x = centerX + radius * cos(angle);
              double y = centerY + radius * sin(angle);

              // قائمة المجالات التقنية
              List<String> categories = [
                'الشبكات',
                'الذكاء الاصطناعي',
                'الحوسبة السحابية',
                'الأمن السيبراني',
                'تحليل البيانات',
                'التعلم الآلي'
              ];

              String label = categories[index]; // أخذ المجال من القائمة

              return _buildTechCircle(label, x, y, index + 1);
            }),
            // دائرة "استمرار" في أسفل اليمين
            Positioned(
              bottom: 50,
              right: 10,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NavigationPage(),
                    ),
                  );
                },
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor:
                  selectedIndex == 7 ? Colors.blue : Colors.orange,
                  child: const Text(
                    'استمرار',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTechCircle(String label, double left, double top, int index) {
    Color circleColor =
    (selectedIndex == index) ? Colors.blue : Colors.orange;

    return Positioned(
      left: left,
      top: top,
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedIndex = (selectedIndex == index) ? -1 : index;
            _storeSelectedCategory(label); // Store the selected category
          });
        },
        child: CircleAvatar(
          radius: 50,
          backgroundColor: circleColor,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo( // Use the Cairo font
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
