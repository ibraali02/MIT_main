import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'AddCoursePage.dart'; // Ensure the AddCoursePage is correctly imported
import 'course_details_page.dart'; // Ensure the CourseDetailsPage is correctly imported

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> categories = [
    'الكل',
    'التكنولوجيا',
    'تكنولوجيا المعلومات',
    'لغات البرمجة',
    'الأمن السيبراني',
    'الذكاء الاصطناعي',
    'علوم البيانات',
    'تطوير الويب',
    'تطوير تطبيقات الهواتف',
  ];

  String selectedCategory = 'الكل';
  String studentName = "جاري التحميل...";
  String? userToken;

  @override
  void initState() {
    super.initState();
    _fetchStudentName();
  }

  // Function to fetch student name and token using the token stored in SharedPreferences
  Future<void> _fetchStudentName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString('token');

    if (userToken != null) {
      var studentDoc = await FirebaseFirestore.instance
          .collection('users') // Assuming 'students' collection holds the student data
          .doc(userToken)
          .get();

      if (studentDoc.exists) {
        setState(() {
          studentName = studentDoc['fullName'] ?? "غير معروف"; // Assuming the field is 'fullName'
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(                automaticallyImplyLeading: false,

        backgroundColor: const Color(0xFF0096AB),
        elevation: 1,
        centerTitle: true,
        title: Text(
          'مرحباً،يا معلم',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cairo',
          ),
        ),
        shape: const ContinuousRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add,
              color: Colors.yellow, // تغيير اللون إلى الأصفر
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddCoursePage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildCategoryDropdown(),
              const SizedBox(height: 20),
              _buildCoursesGrid(),
            ],
          ),
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
              style: const TextStyle(fontSize: 16, fontFamily: 'Cairo'),
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
          return const Center(child: Text('حدث خطأ في تحميل الدورات'));
        }

        final courses = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final category = data['category'] ?? '';
          if (selectedCategory == 'الكل') {
            return true;
          }
          return category == selectedCategory;
        }).toList();

        if (courses.isEmpty) {
          return const Center(
            child: Text(
              'لم يتم العثور على دورات لهذه الفئة.',
              style: TextStyle(fontSize: 16, color: Colors.grey, fontFamily: 'Cairo'),
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

            return FutureBuilder<double>( // Fetch course rating
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
                  course['token'] == userToken, // Check if the course is assigned to the logged-in user
                );
              },
            );
          },
        );
      },
    );
  }

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
      bool isUserCourse, // Indicator for whether this course belongs to the logged-in user
      ) {
    return GestureDetector(
      onTap: () {
        if (isUserCourse) {
          // Proceed to CourseDetailsPage only if the logged-in user is the owner of the course
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CourseDetailsPage(
                courseId: courseId,
                courseName: title,
                imageUrl: imageUrl,
                details: details,
                teacher: teacher,
              ),
            ),
          );
        } else {
          // Show a message if the user is not the course owner
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('لا يمكنك مشاهدة هذه الدورة لأنك لست المالك.'),
              backgroundColor: Colors.red,
            ),
          );
        }
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
        child: Stack(
          children: [
            Column(
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
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0096AB),
                          fontFamily: 'Cairo',
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
                          fontFamily: 'Cairo',
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'المعلم: $teacher',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'الفئة: $category',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFEFAC52),
                          fontFamily: 'Cairo',
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
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ],
                      )
                          : const Text(
                        'لا توجد تقييمات بعد',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (isUserCourse)
              Positioned(
                top: 8,
                right: 8,
                child: Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: 30,
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
