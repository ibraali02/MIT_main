import 'package:flutter/material.dart';

class CourseContentPage extends StatelessWidget {
  final String courseName;
  const CourseContentPage({Key? key, required this.courseName}) : super(key: key);

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
