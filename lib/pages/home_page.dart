import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'course_details_page.dart';
import 'course_registration_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> categories = [
    'All',
    'Technology',
    'Information Technology',
    'Programming Languages',
    'Cybersecurity',
    'Data Science',
    'Web Development',
    'Mobile Development',
    'Artificial Intelligence',
  ];

  String selectedCategory = 'All';
  String studentName = "Loading...";

  @override
  void initState() {
    super.initState();
    _fetchStudentName();
  }

  // Function to fetch student name using the token stored in SharedPreferences
  Future<void> _fetchStudentName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('user_document_id');

    if (token != null) {
      var studentDoc = await FirebaseFirestore.instance
          .collection('students') // Assuming 'students' collection holds the student data
          .doc(token)
          .get();

      if (studentDoc.exists) {
        setState(() {
          studentName = studentDoc['fullName'] ?? "Unknown"; // Assuming the field is 'name'
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0096AB), // استخدام اللون الأول
        elevation: 1,
        centerTitle: true, // لتوسيط العنوان
        title: Text(
          'Hello, $studentName!',
          style: const TextStyle(
            color: Colors.white, // تغيير لون النص إلى الأبيض
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        shape: const ContinuousRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              'What do you wanna learn today?',
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            ),
            const SizedBox(height: 20),
            _buildCategoryDropdown(),
            const SizedBox(height: 20),
            _buildCoursesGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: DropdownButton<String>(
        value: selectedCategory,
        isExpanded: true,
        underline: const SizedBox(),
        items: categories.map((category) {
          return DropdownMenuItem(
            value: category,
            child: Text(
              category,
              style: const TextStyle(fontSize: 16),
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            selectedCategory = value!;
          });
        },
      ),
    );
  }

  Widget _buildCoursesGrid() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('courses').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Error loading courses'));
        }

        final courses = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final category = data['category'] ?? '';
          if (selectedCategory == 'All') {
            return true;
          }
          return category == selectedCategory;
        }).toList();

        if (courses.isEmpty) {
          return const Center(
            child: Text(
              'No courses found for this category.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Display two items per row
            crossAxisSpacing: 16, // Space between columns
            mainAxisSpacing: 16, // Space between rows
            childAspectRatio: 0.7, // Aspect ratio for the course cards
          ),
          itemCount: courses.length,
          itemBuilder: (context, index) {
            final course = courses[index].data() as Map<String, dynamic>;
            final courseId = courses[index].id;

            return FutureBuilder<double>(
              future: _fetchAverageRating(courseId),
              builder: (context, ratingSnapshot) {
                if (ratingSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final avgRating = ratingSnapshot.data ?? 0.0;

                return _buildCourseCard(
                  context,
                  course['image_url'],
                  course['title'],
                  course['details'],
                  course['teacher'],
                  courseId,
                  course['category'],
                  avgRating,
                );
              },
            );
          },
        );
      },
    );
  }

  // Custom function to fetch average rating from ratings sub-collection
  Future<double> _fetchAverageRating(String courseId) async {
    final ratingsSnapshot = await FirebaseFirestore.instance
        .collection('courses')
        .doc(courseId)
        .collection('ratings')
        .get();

    double avgRating = 0.0;
    int ratingCount = 0;

    for (var doc in ratingsSnapshot.docs) {
      final ratingData = doc.data() as Map<String, dynamic>;
      final score = ratingData['overallScore'] ?? 0.0;
      avgRating += score;
      ratingCount++;
    }

    if (ratingCount > 0) {
      avgRating = avgRating / ratingCount;
    }

    return avgRating;
  }

  Widget _buildCourseCard(
      BuildContext context,
      String imageUrl,
      String title,
      String details,
      String teacher,
      String courseId,
      String category,
      double rating,
      ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CourseRegistrationPage(
              courseId: courseId,
              courseName: title,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                imageUrl,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0096AB), // اللون الثاني
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    details,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Teacher: $teacher',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Category: $category',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFEFAC52), // اللون الأول
                    ),
                  ),
                  const SizedBox(height: 4),
                  rating > 0
                      ? Row(
                    children: [
                      _buildRatingStars(rating),
                      const SizedBox(width: 8),
                      Text(
                        rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                      : const Text(
                    'No Rating Yet',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingStars(double rating) {
    List<Widget> stars = [];
    for (int i = 1; i <= 5; i++) {
      if (i <= rating) {
        stars.add(const Icon(Icons.star, color: Colors.amber, size: 16));
      } else {
        stars.add(const Icon(Icons.star_border, color: Colors.amber, size: 16));
      }
    }
    return Row(
      children: stars,
    );
  }
}
