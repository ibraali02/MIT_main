import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'course_details_page.dart';

class SavedPage extends StatefulWidget {
  const SavedPage({super.key});

  @override
  _SavedPageState createState() => _SavedPageState();
}

class _SavedPageState extends State<SavedPage> {
  String? userToken;
  late Future<void> fetchUserToken;

  @override
  void initState() {
    super.initState();
    fetchUserToken = _getTokenFromSharedPreferences();
  }

  Future<void> _getTokenFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userToken = prefs.getString('token'); // Replace 'user_token' with your key
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0096AB),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Saved Courses',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            Container(
              height: 2,
              width: 50,
              color: Colors.white,
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: fetchUserToken,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (userToken == null) {
            return const Center(child: Text('No token found.'));
          }
          return _buildCompletedCoursesList();
        },
      ),
    );
  }

  Widget _buildCompletedCoursesList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('courses')
          .where('token', isEqualTo: userToken)
          .where('completed', isEqualTo: true) // Only fetch completed courses
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading courses.'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No saved courses found.'));
        }

        final courses = snapshot.data!.docs;

        return ListView.builder(
          itemCount: courses.length,
          itemBuilder: (context, index) {
            final course = courses[index].data() as Map<String, dynamic>;
            return ListTile(
              title: Text(
                course['title'],
                style: TextStyle(
                  color: const Color(0xFF0096AB),
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(course['details'], style: TextStyle(color: const Color(0xFFEFAC52))),
              trailing: const Icon(Icons.arrow_forward, color: Color(0xFF0096AB)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CourseDetailsPage(
                      courseId: courses[index].id,
                      courseName: course['title'],
                      imageUrl: course['image_url'],
                      details: course['details'],
                      teacher: course['teacher'],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
