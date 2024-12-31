import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'course_details_page.dart';

class CourseRegistrationPage extends StatelessWidget {
  final String courseId;
  final String courseName;

  CourseRegistrationPage({
    required this.courseId,
    required this.courseName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register for $courseName'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('courses').doc(courseId).get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(child: Text('Error loading course data'));
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text('Course not found'));
            }

            var courseData = snapshot.data!.data() as Map<String, dynamic>;

            // Fetch the course details
            String title = courseData['title'] ?? '';
            String details = courseData['details'] ?? '';
            String imageUrl = courseData['image_url'] ?? '';
            String category = courseData['category'] ?? '';
            String teacher = courseData['teacher'] ?? '';
            String startDate = courseData['start_date'] ?? '';
            var lectures = courseData['lectures'] ?? {};
            var ratings = courseData['ratings'] ?? {};

            // Get number of lectures and ratings
            int numberOfLectures = lectures.length;
            int numberOfRatings = ratings.length;
            int numberOfStudents = courseData['students']?.length ?? 0;  // assuming students are stored in an array

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text('Category: $category'),
                const SizedBox(height: 10),
                Image.network(imageUrl),
                const SizedBox(height: 20),
                Text('Details: $details'),
                const SizedBox(height: 20),
                Text('Teacher: $teacher'),
                const SizedBox(height: 10),
                Text('Start Date: $startDate'),
                const SizedBox(height: 10),
                Text('Number of Lectures: $numberOfLectures'),
                const SizedBox(height: 10),
                Text('Number of Ratings: $numberOfRatings'),
                const SizedBox(height: 10),
                Text('Number of Registered Students: $numberOfStudents'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Handle the "Save" action
                  },
                  child: const Text('Save'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to Course Details Page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CourseDetailsPage(courseId: courseId),
                      ),
                    );
                  },
                  child: const Text('Enroll Now'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
