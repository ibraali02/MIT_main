import 'package:flutter/material.dart';
import 'dart:math';
import 'navigation_page.dart';

class TechCategoriesPage extends StatefulWidget {
  @override
  _TechCategoriesPageState createState() => _TechCategoriesPageState();
}

class _TechCategoriesPageState extends State<TechCategoriesPage> {
  int selectedIndex = -1; // المتغير لتخزين الدائرة المحددة

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''), // إخفاء العنوان في الـ AppBar
      ),
      body: Container(
        color: Colors.white, // خلفية الصفحة بيضاء
        child: Stack(
          children: [
            // السؤال فوق الدوائر
            Positioned(
              top: 50, // المسافة من أعلى الصفحة
              left: 10, // المسافة من اليسار
              child: Text(
                'What do you want to learn?', // السؤال
                style: TextStyle(
                  fontSize: 30, // تكبير حجم النص
                  fontWeight: FontWeight.bold, // جعل الخط بولد
                  color: Colors.black, // لون النص أسود
                ),
              ),
            ),
            // دائرة واحدة في المنتصف
            _buildTechCircle('Center', 150, 300, 0), // مركز الدائرة
            // توزيع الدوائر الأخرى حول المركز
            ...List.generate(6, (index) {
              double angle = (2 * pi / 6) * index; // تحديد الزوايا لكل دائرة
              double radius = 150; // نصف قطر الدائرة
              double centerX = 155; // مركز الدائرة في X
              double centerY = 300; // مركز الدائرة في Y

              // حساب إحداثيات الدوائر بناءً على الزوايا والنصف القطر
              double x = centerX + radius * cos(angle);
              double y = centerY + radius * sin(angle);

              // تسمية الدوائر
              String label = 'Tech ${index + 1}';

              return _buildTechCircle(label, x, y, index + 1); // بناء الدائرة
            }),
            // دائرة comntunuio في أسفل اليمين
            Positioned(
              bottom: 50, // المسافة من أسفل الصفحة
              right: 10, // المسافة من اليمين
              child: GestureDetector(
                onTap: () {
                  // الانتقال إلى الصفحة الجديدة عند الضغط
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NavigationPage(),
                    ),
                  );
                },
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor:
                  selectedIndex == 7 ? Colors.blue : Colors.orange,
                  child: Text(
                    'comntunuio',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // النص داخل الدائرة باللون الأبيض
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
    // تحديد اللون بناءً على إذا كانت الدائرة المحددة أم لا
    Color circleColor =
    (selectedIndex == index) ? Colors.blue : Colors.orange;

    return Positioned(
      left: left,
      top: top,
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedIndex = (selectedIndex == index) ? -1 : index;
          });
        },
        child: CircleAvatar(
          radius: 50,
          backgroundColor: circleColor, // استخدام اللون المحدد
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white, // النص داخل الدائرة باللون الأبيض
            ),
          ),
        ),
      ),
    );
  }
}
