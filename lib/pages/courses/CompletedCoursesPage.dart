import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CompletedCoursesPage extends StatefulWidget {
  const CompletedCoursesPage({super.key});

  @override
  _CompletedCoursesPageState createState() => _CompletedCoursesPageState();
}

class _CompletedCoursesPageState extends State<CompletedCoursesPage> {
  late Future<List<Map<String, dynamic>>> _completedCoursesFuture;

  @override
  void initState() {
    super.initState();
    _completedCoursesFuture = _fetchCompletedCourses();
  }

  Future<List<Map<String, dynamic>>> _fetchCompletedCourses() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userToken = prefs.getString('user_document_id');

    if (userToken == null) {
      throw Exception("User token not found. Please log in again.");
    }

    // Fetch completed courses from Firestore
    final QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
        .collection('students')
        .doc(userToken)
        .collection('completed_courses')
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<Map<String, dynamic>> _fetchCourseDetails(String courseId) async {
    final DocumentSnapshot<Map<String, dynamic>> courseSnapshot = await FirebaseFirestore.instance
        .collection('courses')
        .doc(courseId)
        .get();

    if (!courseSnapshot.exists) {
      throw Exception('Course not found');
    }

    return courseSnapshot.data() ?? {};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Completed Courses'),
        backgroundColor: const Color(0xFF0096AB),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _completedCoursesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final completedCourses = snapshot.data;

          if (completedCourses == null || completedCourses.isEmpty) {
            return const Center(
              child: Text(
                'No completed courses found.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            );
          }

          return ListView.builder(
            itemCount: completedCourses.length,
            itemBuilder: (context, index) {
              final course = completedCourses[index];
              final courseId = course['course_id'] ?? 'N/A';

              // Fetch course details by course_id
              return FutureBuilder<Map<String, dynamic>>(
                future: _fetchCourseDetails(courseId),
                builder: (context, courseSnapshot) {
                  if (courseSnapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  if (courseSnapshot.hasError) {
                    return Text('Error fetching course details');
                  }

                  final courseDetails = courseSnapshot.data ?? {};
                  final category = courseDetails['category'] ?? 'No category';
                  final details = courseDetails['details'] ?? 'No details available';
                  final imageUrl = courseDetails['image_url'] ?? '';
                  final teacher = courseDetails['teacher'] ?? 'No teacher info';
                  final title = courseDetails['title'] ?? 'No title';

                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    elevation: 4.0,
                    color: const Color(0xFFEFAC52),
                    child: ListTile(
                      title: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Category: $category',
                            style: const TextStyle(color: Colors.white),
                          ),
                          Text(
                            'Teacher: $teacher',
                            style: const TextStyle(color: Colors.white),
                          ),
                          Text(
                            'Details: $details',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      trailing: imageUrl.isNotEmpty
                          ? Image.network(imageUrl, width: 100, height: 100)
                          : const Icon(Icons.check_circle, color: Colors.white),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
