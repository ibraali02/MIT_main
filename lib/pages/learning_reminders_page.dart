import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'LearningCategoriesPage.dart';

class LearningRemindersPage extends StatefulWidget {
  const LearningRemindersPage({super.key});

  @override
  _LearningRemindersPageState createState() => _LearningRemindersPageState();
}

class _LearningRemindersPageState extends State<LearningRemindersPage> {
  int selectedHour = 14;
  int selectedMinute = 30;
  Set<String> selectedDays = {};
  final Color defaultColor = const Color(0xFFEFAC52);
  final Color selectedColor = const Color(0xFF0096AB);
  late String userDocumentId;

  @override
  void initState() {
    super.initState();
    _getUserDocumentId();
  }

  _getUserDocumentId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userDocumentId = prefs.getString('user_document_id') ?? '';
    });
  }

  _storeReminderData() async {
    if (userDocumentId.isNotEmpty) {
      FirebaseFirestore.instance.collection('students').doc(userDocumentId).update({
        'reminders': {
          'hour': selectedHour,
          'minute': selectedMinute,
          'days': selectedDays.toList(),
        },
      }).then((value) {
        print('Reminder data stored successfully');
      }).catchError((error) {
        print('Error storing reminder data: $error');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: () async {
          Navigator.pop(context);
          return true;
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: <Widget>[
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'إعداد تذكيرات التعلم',
                style: GoogleFonts.cairo(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 20),
              Text(
                'أخبرنا متى تريد التعلم وسنرسل لك إشعارات للتذكير.',
                textAlign: TextAlign.right,
                style: GoogleFonts.cairo(fontSize: 16, color: Colors.black),
              ),
              const SizedBox(height: 40),
              SizedBox(
                height: 80,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: <Widget>[
                    _buildDayButton('Thu'),
                    const SizedBox(width: 20),
                    _buildDayButton('Fri'),
                    const SizedBox(width: 20),
                    _buildDayButton('Sat'),
                    const SizedBox(width: 20),
                    _buildDayButton('Sun'),
                    const SizedBox(width: 20),
                    _buildDayButton('Mon'),
                    const SizedBox(width: 20),
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
                          itemCount: 24,
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
                            color: Colors.black,
                          ),
                        ),
                        _buildTimePicker(
                          itemCount: 60,
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
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.all(20),
                    ),
                    child: const Text('تخطي', style: TextStyle(color: Colors.black)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _storeReminderData(); // حفظ التذكيرات
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const TechCategoriesPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.all(40),
                    ),
                    child: const Text('استمرار', style: TextStyle(color: Colors.white, fontSize: 22)),
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
    bool isSelected = selectedDays.contains(day);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            selectedDays.remove(day);
          } else {
            selectedDays.add(day);
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: isSelected ? selectedColor : defaultColor,
        ),
        child: Text(
          day,
          style: GoogleFonts.cairo(
            fontSize: 20,
            color: Colors.black,
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
            String text = index.toString().padLeft(2, '0');
            return Center(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: isSelected ? 30 : 20,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: Colors.black,
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
