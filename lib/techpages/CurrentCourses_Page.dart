import 'package:flutter/material.dart';

class CurrentCoursesPage extends StatelessWidget {
  const CurrentCoursesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Current Courses'),
        backgroundColor: Colors.blueAccent,
      ),
      body: const Center(
        child: Text(
          'List of Current Courses',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
