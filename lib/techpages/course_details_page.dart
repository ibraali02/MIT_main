import 'package:flutter/material.dart';
import 'course_content_page.dart';

class CourseDetailsPage extends StatelessWidget {
  final String courseName;
  const CourseDetailsPage({super.key, required this.courseName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(courseName),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CourseContentPage(courseName: courseName),
              ),
            );
          },
          child: const Text('Go to Lectures and Tests'),
        ),
      ),
    );
  }
}
