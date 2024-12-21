import 'package:flutter/material.dart';

class CurrentCoursesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Current Courses'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Text(
          'List of Current Courses',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
