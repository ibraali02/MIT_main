import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

    // Fetch enrolled courses from Firestore
    final QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
        .collection('students')
        .doc(userToken)
        .collection('course_enrolled')
        .get();

    return snapshot.docs.map((doc) {
      return {
        'id': doc.id, // Store the document ID for deletion
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

    // Check if the course is already completed
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

    // Add course to completed_courses
    await studentRef.collection('completed_courses').add({
      'course_id': courseId,
      'completed_at': FieldValue.serverTimestamp(),
    });

    // Remove course from course_enrolled
    await studentRef
        .collection('course_enrolled')
        .doc(documentId)
        .delete();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Course $courseId marked as completed and removed from enrolled courses!')),
    );

    // Refresh the courses list
    setState(() {
      _coursesFuture = _fetchEnrolledCourses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Current Courses'),
        backgroundColor: Colors.blueAccent,
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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            );
          }

          return ListView.builder(
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];
              final courseName = course['course_name'] ?? 'Unknown Course';
              final courseId = course['course_id'] ?? 'N/A';
              final documentId = course['id']; // Document ID for deletion
              final enrolledAt = course['enrolled_at']?.toDate().toString() ?? 'N/A';

              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(
                    courseName,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Course ID: $courseId\nEnrolled At: $enrolledAt'),
                  trailing: ElevatedButton(
                    onPressed: () => _markCourseAsCompleted(courseId, documentId),
                    child: const Text('Mark as Completed'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
