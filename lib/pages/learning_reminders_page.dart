import 'package:flutter/material.dart';

import 'LearningCategoriesPage.dart';

class LearningRemindersPage extends StatefulWidget {
  const LearningRemindersPage({super.key});

  @override
  _LearningRemindersPageState createState() => _LearningRemindersPageState();
}

class _LearningRemindersPageState extends State<LearningRemindersPage> {
  int selectedHour = 14; // الساعة الافتراضية
  int selectedMinute = 30; // الدقيقة الافتراضية
  Set<String> selectedDays = {}; // لتخزين الأيام المحددة
  final Color defaultColor = const Color(0xFFEFAC52); // اللون الافتراضي
  final Color selectedColor = const Color(0xFF0096AB); // اللون عند التحديد

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: () async {
          Navigator.pop(context); // العودة إلى الصفحة السابقة عند الضغط على السهم
          return true;
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: <Widget>[
              // إضافة السهم الرجعي يدويًا
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () {
                      Navigator.pop(context); // العودة للصفحة السابقة
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // إضافة النص "Set up learning reminders" أعلى الصفحة بحجم أكبر وبولد
              const Text(
                'Set up learning reminders',
                style: TextStyle(
                  fontSize: 30, // حجم أكبر
                  fontWeight: FontWeight.bold, // جعل الخط بولد
                  color: Colors.black, // لون النص أسود
                ),
                textAlign: TextAlign.left, // محاذاة النص لليسار
              ),
              const SizedBox(height: 20),
              // إضافة النص الحالي ليكون محاذيًا لليسار
              const Text(
                'Tell us when you want to learn and we will send push notifications to remind you.',
                textAlign: TextAlign.left, // محاذاة النص لليسار
                style: TextStyle(fontSize: 16, color: Colors.black), // تغيير اللون إلى الأسود
              ),
              const SizedBox(height: 40),
              // تعديل الأيام بحيث يمكن تمريرها أفقيًا
              SizedBox(
                height: 80, // زيادة ارتفاع الحاوية
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: <Widget>[
                    _buildDayButton('Thu'),
                    const SizedBox(width: 20), // إضافة مسافة بين الأيام
                    _buildDayButton('Fri'),
                    const SizedBox(width: 20), // إضافة مسافة بين الأيام
                    _buildDayButton('Sat'),
                    const SizedBox(width: 20), // إضافة مسافة بين الأيام
                    _buildDayButton('Sun'),
                    const SizedBox(width: 20), // إضافة مسافة بين الأيام
                    _buildDayButton('Mon'),
                    const SizedBox(width: 20), // إضافة مسافة بين الأيام
                    _buildDayButton('Tue'),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildTimePicker(
                          itemCount: 24, // ساعات 0 إلى 23
                          selectedValue: selectedHour,
                          onChanged: (value) {
                            setState(() {
                              selectedHour = value;
                            });
                          },
                        ),
                        const Text(
                          ":",
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.black, // تغيير اللون إلى أسود
                          ),
                        ),
                        _buildTimePicker(
                          itemCount: 60, // دقائق 0 إلى 59
                          selectedValue: selectedMinute,
                          onChanged: (value) {
                            setState(() {
                              selectedMinute = value;
                            });
                          },
                        ),
                      ],
                    ),
                    const Positioned(
                      top: 75,
                      left: 0,
                      right: 0,
                      child: Divider(
                        color: Colors.black,
                        thickness: 2,
                      ),
                    ),
                    const Positioned(
                      bottom: 75,
                      left: 0,
                      right: 0,
                      child: Divider(
                        color: Colors.black,
                        thickness: 2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      // Skip logic
                    },
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      backgroundColor: Colors.greenAccent,
                      padding: const EdgeInsets.all(20),
                    ),
                    child: const Text('Skip', style: TextStyle(color: Colors.black)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Continue logic
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const TechCategoriesPage()),
                      );
                    }, // Increased font size
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.all(40), // Increased padding for a larger button
                    ),
                    child: const Text('Continue', style: TextStyle(color: Colors.white, fontSize: 22)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDayButton(String day) {
    bool isSelected = selectedDays.contains(day); // التحقق إذا كان اليوم محددًا
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            selectedDays.remove(day); // إذا كان محددًا مسبقًا، نقوم بإزالته
          } else {
            selectedDays.add(day); // إذا لم يكن محددًا، نقوم بإضافته
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.all(20), // زيادة الحشو داخل الأزرار
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: isSelected ? selectedColor : defaultColor, // اللون عند التحديد يصبح 0096AB
        ),
        child: Text(
          day,
          style: const TextStyle(
            fontSize: 20,
            color: Colors.black, // النص يصبح باللون الأسود
          ),
        ),
      ),
    );
  }

  Widget _buildTimePicker({
    required int itemCount,
    required int selectedValue,
    required ValueChanged<int> onChanged,
  }) {
    return Expanded(
      child: ListWheelScrollView.useDelegate(
        itemExtent: 70,
        perspective: 0.005,
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged: onChanged,
        childDelegate: ListWheelChildBuilderDelegate(
          builder: (context, index) {
            bool isSelected = index == selectedValue;
            String text = index.toString().padLeft(2, '0'); // عرض الرقم بصيغة 2 أرقام
            return Center(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: isSelected ? 30 : 20, // تكبير الرقم في المنتصف
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, // Bold للرقم في المنتصف
                  color: Colors.black, // اللون الأسود لجميع الأرقام
                ),
              ),
            );
          },
          childCount: itemCount,
        ),
      ),
    );
  }
}
