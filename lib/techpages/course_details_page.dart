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

  const CourseDetailsPage({
    super.key,
    required this.courseId,
    required this.courseName,
    required this.imageUrl,
    required this.details,
    required this.teacher,
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
        title: Text(
          widget.courseName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF0096AB),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.orange, // Orange indicator when selected
          labelColor: Colors.orange, // Orange color for selected tab
          unselectedLabelColor: Colors.white, // White color for unselected tab
          tabs: [
            _buildTab(Icons.info),
            _buildTab(Icons.comment),
            _buildTab(Icons.video_library),
            _buildTab(Icons.video_call),
            _buildTab(Icons.star),
            _buildTab(Icons.assignment), // Added Exams tab
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

  // Function to build a Tab with icon only
  Tab _buildTab(IconData icon) {
    return Tab(
      icon: Icon(icon),
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
          // Course Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imageUrl,
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 16),

          // Course Title
          Text(
            courseName,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0096AB),
            ),
          ),
          const SizedBox(height: 8),

          // Teacher Name
          Text(
            'Teacher: $teacher',
            style: const TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 16),

          // Course Details
          Text(
            details,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),

          // Course ID (Token)
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
