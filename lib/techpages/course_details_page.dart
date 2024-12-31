import 'package:flutter/material.dart';
import 'courses/comments_page.dart';
import 'courses/lectures_page.dart';
import 'courses/videos_page.dart';
import 'courses/ratings_page.dart';
import 'courses/examspage.dart'; // Import the ExamsPage

class CourseDetailsPage extends StatefulWidget {
  final String courseId;
  final String courseName;
  final String imageUrl;
  final String details;
  final String teacher;
  final String startDate;

  const CourseDetailsPage({
    super.key,
    required this.courseId,
    required this.courseName,
    required this.imageUrl,
    required this.details,
    required this.teacher,
    required this.startDate,
  });

  @override
  _CourseDetailsPageState createState() => _CourseDetailsPageState();
}

class _CourseDetailsPageState extends State<CourseDetailsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this); // Updated length
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.courseName),
        backgroundColor: Colors.green,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Details'),
            Tab(text: 'Comments'),
            Tab(text: 'Lectures'),
            Tab(text: 'Videos'),
            Tab(text: 'Ratings'),
            Tab(text: 'Exams'), // Added Exams tab
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          CourseDetailsTab(
            courseId: widget.courseId,
            courseName: widget.courseName,
            imageUrl: widget.imageUrl,
            details: widget.details,
            teacher: widget.teacher,
            startDate: widget.startDate,
          ),
          CommentsPage(courseId: widget.courseId),
          LecturesPage(courseId: widget.courseId),
          VideosPage(courseId: widget.courseId),
          RatingsPage(courseId: widget.courseId),
          ExamsPage(courseId: widget.courseId), // Added ExamsPage
        ],
      ),
    );
  }
}

class CourseDetailsTab extends StatelessWidget {
  final String courseId;
  final String courseName;
  final String imageUrl;
  final String details;
  final String teacher;
  final String startDate;

  const CourseDetailsTab({
    super.key,
    required this.courseId,
    required this.courseName,
    required this.imageUrl,
    required this.details,
    required this.teacher,
    required this.startDate,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            imageUrl,
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 16),
          Text(
            courseName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Teacher: $teacher',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start Date: $startDate',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            details,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Course ID (Token): $courseId',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
}
