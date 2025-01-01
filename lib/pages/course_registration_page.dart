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
      final String? userToken = prefs.getString('user_token');

      if (userToken == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User token not found. Please log in again.')),
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
          const SnackBar(content: Text('Course is already saved!')),
        );
        return;
      }

      await savedCoursesRef.set({
        'course_name': courseName,
        'course_id': courseId,
        'saved_at': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Course saved successfully!')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving course: $error')),
      );
    }
  }

  Future<void> _enrollCourse(BuildContext context) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? userToken = prefs.getString('user_token');

      if (userToken == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User token not found. Please log in again.')),
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
          const SnackBar(content: Text('You are already enrolled in this course!')),
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
        const SnackBar(content: Text('You have been enrolled successfully!')),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CourseDetailsPage(courseId: courseId),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error enrolling in course: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Register for $courseName',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
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
              return const Center(child: Text('Error loading course data'));
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text('Course not found'));
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
                  // Card for course details
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
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Category: $category',
                            style: TextStyle(fontSize: 16, color: Colors.black87),
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
                            'Details:',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0096AB),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            details,
                            style: TextStyle(fontSize: 16, color: Colors.black87),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Teacher: $teacher',
                            style: TextStyle(fontSize: 16, color: Colors.black87),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Start Date: $startDate',
                            style: TextStyle(fontSize: 16, color: Colors.black87),
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
                                    'Lectures: $numberOfLectures',
                                    style: TextStyle(fontSize: 16, color: Colors.black87),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(Icons.star, color: Color(0xFFEFAC52)),
                                  SizedBox(width: 5),
                                  Text(
                                    'Ratings: $numberOfRatings',
                                    style: TextStyle(fontSize: 16, color: Colors.black87),
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
                                'Students: $numberOfStudents',
                                style: TextStyle(fontSize: 16, color: Colors.black87),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Centered Save Button
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () => _saveCourse(context),
                      icon: Icon(Icons.save_alt, color: Colors.white),
                      label: const Text(
                        'Save Course',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
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
                  // Centered Enroll Button
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () => _enrollCourse(context),
                      icon: Icon(Icons.school, color: Colors.white),
                      label: const Text(
                        'Enroll Now',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
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
