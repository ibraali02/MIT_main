import 'package:flutter/material.dart';

class CourseContentPage extends StatelessWidget {
  final String courseName;
  const CourseContentPage({super.key, required this.courseName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$courseName Content'),
      ),
      body: const Center(
        child: Text('Lectures and Tests go here!'),
      ),
    );
  }
}
