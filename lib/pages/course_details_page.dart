import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  // Fetch course details from Firestore
  Future<Map<String, String>> fetchCourseDetails(String courseId) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('courses').doc(courseId).get();

      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        return {
          'courseName': data['title'] ?? 'No Title',
          'imageUrl': data['image_url'] ?? '',
          'details': data['details'] ?? 'No details available',
          'teacher': data['teacher'] ?? 'No teacher info',
        };
      } else {
        throw 'Course not found';
      }
    } catch (e) {
      throw 'Error fetching course data: $e';
    }
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
              backgroundColor: Color(0xFF0096AB), // Blue color
            ),
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Error'),
              backgroundColor: Color(0xFF0096AB), // Blue color
            ),
            body: Center(child: Text('Error loading course details')),
          );
        } else if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              title: Text('No Data'),
              backgroundColor: Color(0xFF0096AB), // Blue color
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
            title: Text(
              courseName,
              style: TextStyle(
                fontWeight: FontWeight.bold, // Make the title bold
                color: Colors.white, // Set text color to white
              ),
            ),
            backgroundColor: Color(0xFF0096AB), // Blue color
            iconTheme: IconThemeData(
              color: Color(0xFFEFAC52), // Orange color for the back icon
            ),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Color(0xFFEFAC52), // Orange color for indicator
              unselectedLabelColor: Colors.white, // White color for unselected tab
              labelColor: Color(0xFFEFAC52), // Orange color for selected tab
              tabs: const [
                Tab(icon: Icon(Icons.info_outline)), // Icon for Details
                Tab(icon: Icon(Icons.comment)), // Icon for Comments
                Tab(icon: Icon(Icons.picture_as_pdf_rounded)), // Icon for Lectures
                Tab(icon: Icon(Icons.video_library)), // Icon for Videos
                Tab(icon: Icon(Icons.star_border)), // Icon for Ratings
                Tab(icon: Icon(Icons.assignment)), // Icon for Exams
              ],
            ),
          ),
          body: Container(
            color: Colors.white, // White background for the body
            child: TabBarView(
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
      padding: const EdgeInsets.all(20.0), // Increased padding for better spacing
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15), // Rounded corners for the image
            child: Image.network(
              imageUrl,
              width: double.infinity,
              height: 250, // Increased height for better visuals
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 20),

          // Course details inside a Card widget
          Card(
            elevation: 5, // Adds shadow
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10), // Rounded corners for the card
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0), // Padding inside the card
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    courseName,
                    style: const TextStyle(
                      fontSize: 28, // Increased font size for course name
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Instructor: $teacher',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    details,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
