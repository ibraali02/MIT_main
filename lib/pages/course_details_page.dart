import 'package:flutter/material.dart';
import 'courses/ExamPage.dart';
import 'courses/comments_page.dart';
import 'courses/lectures_page.dart';
import 'courses/videos_page.dart';
import 'courses/ratings_page.dart';
import 'courses/examspage.dart'; // Import the ExamsPage

class CourseDetailsPage extends StatefulWidget {
  final String courseId;

  const CourseDetailsPage({
    super.key,
    required this.courseId,
  });

  @override
  _CourseDetailsPageState createState() => _CourseDetailsPageState();
}

class _CourseDetailsPageState extends State<CourseDetailsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Sample function to simulate fetching course details based on courseId
  Future<Map<String, String>> fetchCourseDetails(String courseId) async {
    await Future.delayed(Duration(seconds: 2)); // Simulate a network call
    // Return dummy data for now
    return {
      'courseName': 'Course Name for $courseId',
      'imageUrl': 'https://via.placeholder.com/150',
      'details': 'Detailed information about the course $courseId.',
      'teacher': 'Teacher for $courseId',
    };
  }

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
    return FutureBuilder<Map<String, String>>(
      future: fetchCourseDetails(widget.courseId), // Fetch course details based on courseId
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Loading...'),
            ),
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Error'),
            ),
            body: Center(child: Text('Error loading course details')),
          );
        } else if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              title: Text('No Data'),
            ),
            body: Center(child: Text('No course data available')),
          );
        }

        // Extract course data from the snapshot
        final courseData = snapshot.data!;
        final courseName = courseData['courseName']!;
        final imageUrl = courseData['imageUrl']!;
        final details = courseData['details']!;
        final teacher = courseData['teacher']!;

        return Scaffold(
          appBar: AppBar(
            title: Text(courseName),
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
                courseName: courseName,
                imageUrl: imageUrl,
                details: details,
                teacher: teacher,
              ),
              CommentsPage(courseId: widget.courseId),
              LecturesPage(courseId: widget.courseId),
              VideosPage(courseId: widget.courseId),
              RatingsPage(courseId: widget.courseId),
              ExamsPage(courseId: widget.courseId), // Added ExamsPage
            ],
          ),
        );
      },
    );
  }
}

class CourseDetailsTab extends StatelessWidget {
  final String courseId;
  final String courseName;
  final String imageUrl;
  final String details;
  final String teacher;

  const CourseDetailsTab({
    super.key,
    required this.courseId,
    required this.courseName,
    required this.imageUrl,
    required this.details,
    required this.teacher,
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
