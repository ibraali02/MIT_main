import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'course_details_page.dart';

class CourseRegistrationPage extends StatelessWidget {
  final String courseId;
  final String courseName;

  CourseRegistrationPage({
    required this.courseId,
    required this.courseName,
  });

  Future<void> _saveCourse(BuildContext context) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? userToken = prefs.getString('user_document_id');

      if (userToken == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('رمز المستخدم غير موجود. الرجاء تسجيل الدخول مرة أخرى.')),
        );
        return;
      }

      final DocumentReference savedCoursesRef = FirebaseFirestore.instance
          .collection('students')
          .doc(userToken)
          .collection('saved_courses')
          .doc(courseId);

      final DocumentSnapshot savedCourse = await savedCoursesRef.get();

      if (savedCourse.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الدورة محفوظة بالفعل!')),
        );
        return;
      }

      await savedCoursesRef.set({
        'course_name': courseName,
        'course_id': courseId,
        'saved_at': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ الدورة بنجاح!')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في حفظ الدورة: $error')),
      );
    }
  }

  Future<void> _enrollCourse(BuildContext context) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? userToken = prefs.getString('user_document_id');

      if (userToken == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('رمز المستخدم غير موجود. الرجاء تسجيل الدخول مرة أخرى.')),
        );
        return;
      }

      final DocumentReference enrolledCoursesRef = FirebaseFirestore.instance
          .collection('students')
          .doc(userToken)
          .collection('course_enrolled')
          .doc(courseId);

      final DocumentSnapshot enrolledCourse = await enrolledCoursesRef.get();

      if (enrolledCourse.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('أنت مسجل بالفعل في هذه الدورة!')),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CourseDetailsPage(courseId: courseId),
          ),
        );
        return;
      }

      await enrolledCoursesRef.set({
        'course_name': courseName,
        'course_id': courseId,
        'enrolled_at': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم التسجيل في الدورة بنجاح!')),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CourseDetailsPage(courseId: courseId),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في التسجيل في الدورة: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'التسجيل في $courseName',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            fontFamily: 'Cairo',
          ),
        ),
        backgroundColor: Color(0xFF0096AB),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('courses').doc(courseId).get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(child: Text('خطأ في تحميل بيانات الدورة'));
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text('الدورة غير موجودة'));
            }

            var courseData = snapshot.data!.data() as Map<String, dynamic>;

            String title = courseData['title'] ?? '';
            String details = courseData['details'] ?? '';
            String imageUrl = courseData['image_url'] ?? '';
            String category = courseData['category'] ?? '';
            String teacher = courseData['teacher'] ?? '';
            String startDate = courseData['start_date'] ?? '';
            var lectures = courseData['lectures'] ?? {};
            var ratings = courseData['ratings'] ?? {};

            int numberOfLectures = lectures.length;
            int numberOfRatings = ratings.length;
            int numberOfStudents = courseData['students']?.length ?? 0;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0096AB),
                              fontFamily: 'Cairo',
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'الفئة: $category',
                            style: TextStyle(fontSize: 16, color: Colors.black87, fontFamily: 'Cairo'),
                          ),
                          const SizedBox(height: 12),
                          Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                imageUrl,
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'التفاصيل:',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0096AB),
                              fontFamily: 'Cairo',
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            details,
                            style: TextStyle(fontSize: 16, color: Colors.black87, fontFamily: 'Cairo'),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'المدرس: $teacher',
                            style: TextStyle(fontSize: 16, color: Colors.black87, fontFamily: 'Cairo'),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'تاريخ البدء: $startDate',
                            style: TextStyle(fontSize: 16, color: Colors.black87, fontFamily: 'Cairo'),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.book, color: Color(0xFF0096AB)),
                                  SizedBox(width: 5),
                                  Text(
                                    'الدروس: $numberOfLectures',
                                    style: TextStyle(fontSize: 16, color: Colors.black87, fontFamily: 'Cairo'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(Icons.people, color: Color(0xFF0096AB)),
                              SizedBox(width: 5),
                              Text(
                                'الطلاب: $numberOfStudents',
                                style: TextStyle(fontSize: 16, color: Colors.black87, fontFamily: 'Cairo'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () => _saveCourse(context),
                      icon: Icon(Icons.save_alt, color: Colors.white),
                      label: const Text(
                        'حفظ الدورة',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Cairo'),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF0096AB),
                        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                        textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 5,
                        shadowColor: Colors.black.withOpacity(0.3),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () => _enrollCourse(context),
                      icon: Icon(Icons.school, color: Colors.white),
                      label: const Text(
                        'التسجيل الآن',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Cairo'),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFEFAC52),
                        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                        textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 5,
                        shadowColor: Colors.black.withOpacity(0.3),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
