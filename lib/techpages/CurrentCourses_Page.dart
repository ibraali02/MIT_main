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
              'Current Courses',
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
          return _buildCoursesList();
        },
      ),
    );
  }
  Widget _buildCoursesList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('courses')
          .where('token', isEqualTo: userToken)
          .where('isCompleted', isEqualTo: false) // فقط استرجاع الدورات غير المكتملة
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading courses.'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No courses found.'));
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
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_forward, color: Color(0xFF0096AB)),
                    onPressed: () {
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
                  ),
                  ElevatedButton(
                    onPressed: () => _markCourseAsCompleted(courses[index].id),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color(0xFF0096AB), // لون النص
                    ),
                    child: const Text('انتهاء'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
  // Function to mark the course as completed
  Future<void> _markCourseAsCompleted(String courseId) async {
    try {
      await FirebaseFirestore.instance.collection('courses').doc(courseId).update({
        'completed': true, // Update the completed field to true
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Course marked as completed!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to mark course as completed.')),
      );
    }
  }
}
