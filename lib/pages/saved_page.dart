import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SavedPage extends StatefulWidget {
  const SavedPage({super.key});

  @override
  _SavedPageState createState() => _SavedPageState();
}

class _SavedPageState extends State<SavedPage> {
  late Future<List<Map<String, dynamic>>> _savedCoursesFuture;

  @override
  void initState() {
    super.initState();
    _savedCoursesFuture = _fetchSavedCourses();
  }

  Future<List<Map<String, dynamic>>> _fetchSavedCourses() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userToken = prefs.getString('user_document_id');

    if (userToken == null) {
      throw Exception("User token not found. Please log in again.");
    }

    // Fetch saved courses from Firestore
    final QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
        .collection('students')
        .doc(userToken)
        .collection('saved_courses')
        .get();

    return snapshot.docs.map((doc) {
      return {
        'id': doc.id, // Store the document ID for deletion
        ...doc.data(),
      };
    }).toList();
  }

  Future<void> _deleteSavedCourse(String courseId, String documentId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userToken = prefs.getString('user_document_id');

    if (userToken == null) {
      throw Exception("User token not found. Please log in again.");
    }

    final DocumentReference studentRef =
    FirebaseFirestore.instance.collection('students').doc(userToken);

    // Delete the saved course
    await studentRef.collection('saved_courses').doc(documentId).delete();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Course $courseId removed from saved courses!')),
    );

    // Refresh the courses list
    setState(() {
      _savedCoursesFuture = _fetchSavedCourses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Courses'),
        backgroundColor: Colors.blueAccent,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _savedCoursesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final savedCourses = snapshot.data;

          if (savedCourses == null || savedCourses.isEmpty) {
            return const Center(
              child: Text(
                'No saved courses found.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            );
          }

          return ListView.builder(
            itemCount: savedCourses.length,
            itemBuilder: (context, index) {
              final course = savedCourses[index];
              final courseName = course['course_name'] ?? 'Unknown Course';
              final courseId = course['course_id'] ?? 'N/A';
              final documentId = course['id']; // Document ID for deletion
              final savedAt = course['saved_at']?.toDate().toString() ?? 'N/A';

              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(
                    courseName,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Course ID: $courseId\nSaved At: $savedAt'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      _deleteSavedCourse(courseId, documentId);
                    },
                  ),
                  onTap: () {
                    // Handle card tap if needed
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Tapped on $courseName')),
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
