import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'course_details_page.dart';

class CurrentCoursesPage extends StatefulWidget {
  const CurrentCoursesPage({super.key});

  @override
  _CurrentCoursesPageState createState() => _CurrentCoursesPageState();
}

class _CurrentCoursesPageState extends State<CurrentCoursesPage> {
  late Future<List<Map<String, dynamic>>> _coursesFuture;

  @override
  void initState() {
    super.initState();
    _coursesFuture = _fetchEnrolledCourses();
  }

  Future<List<Map<String, dynamic>>> _fetchEnrolledCourses() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userToken = prefs.getString('user_document_id');

    if (userToken == null) {
      throw Exception("User token not found. Please log in again.");
    }

    final QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
        .collection('students')
        .doc(userToken)
        .collection('course_enrolled')
        .get();

    return snapshot.docs.map((doc) {
      return {
        'id': doc.id,
        ...doc.data(),
      };
    }).toList();
  }

  Future<void> _markCourseAsCompleted(String courseId, String documentId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userToken = prefs.getString('user_document_id');

    if (userToken == null) {
      throw Exception("User token not found. Please log in again.");
    }

    final DocumentReference studentRef =
    FirebaseFirestore.instance.collection('students').doc(userToken);

    final QuerySnapshot completedCourses = await studentRef
        .collection('completed_courses')
        .where('course_id', isEqualTo: courseId)
        .get();

    if (completedCourses.docs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Course $courseId is already marked as completed!')),
      );
      return;
    }

    await studentRef.collection('completed_courses').add({
      'course_id': courseId,
      'completed_at': FieldValue.serverTimestamp(),
    });

    await studentRef.collection('course_enrolled').doc(documentId).delete();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Course $courseId marked as completed!')),
    );

    setState(() {
      _coursesFuture = _fetchEnrolledCourses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          child: AppBar( automaticallyImplyLeading: false,
            backgroundColor: const Color(0xFF0096AB),
            centerTitle: true,
            title: const Text(
              'Current Courses',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _coursesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final courses = snapshot.data;

          if (courses == null || courses.isEmpty) {
            return const Center(
              child: Text(
                'No enrolled courses found.',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0096AB),
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];
              final courseName = course['course_name'] ?? 'Unknown Course';
              final courseId = course['course_id'] ?? 'N/A';
              final documentId = course['id'];
              final enrolledAt = course['enrolled_at']?.toDate().toString() ?? 'N/A';

              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(
                    courseName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0096AB),
                    ),
                  ),
                  subtitle: Text(
                    'Course ID: $courseId\nEnrolled At: $enrolledAt',
                    style: const TextStyle(color: Color(0xFFEFAC52)),
                  ),
                  trailing: ElevatedButton(
                    onPressed: () => _markCourseAsCompleted(courseId, documentId),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEFAC52), // لون الخلفية
                      foregroundColor: const Color(0xFFffffff), // لون النص
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8), // زوايا مستديرة
                      ),
                    ),
                    child: const Text('Mark as Completed'),
                  ),

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CourseDetailsPage(
                          courseId: courseId,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
