import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'course_registration_page.dart';
import 'package:intl/intl.dart' as s;// Ensure the AddCoursePage is correctly imported

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> categories = [
    'الكل',
    'التكنولوجيا',
    'تقنية المعلومات',
    'لغات البرمجة',
    'أمن المعلومات',
    'البيانات الضخمة',
    'تطوير الويب',
    'تطوير الهواتف',
    'الذكاء الاصطناعي',
  ];

  String selectedCategory = 'الكل';
  String studentName = "جاري التحميل...";

  @override
  void initState() {
    super.initState();
    _fetchStudentName();
  }

  Future<void> _fetchStudentName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('user_document_id');

    if (token != null) {
      var studentDoc = await FirebaseFirestore.instance
          .collection('students')
          .doc(token)
          .get();

      if (studentDoc.exists) {
        setState(() {
          studentName = studentDoc['fullName'] ?? "مجهول";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF0096AB),
        elevation: 1,
        centerTitle: true,
        title: Text(
          'مرحباً، $studentName!',
          style: GoogleFonts.cairo(
            textStyle: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        shape: const ContinuousRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                'ماذا ترغب في تعلمه اليوم؟',
                style: GoogleFonts.cairo(
                  textStyle: TextStyle(fontSize: 18, color: Colors.grey[700]),
                ),
              ),
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
              style: GoogleFonts.cairo(textStyle: const TextStyle(fontSize: 16)),
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
          return const Center(child: Text('حدث خطأ أثناء تحميل الدورات'));
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
              'لا توجد دورات في هذه الفئة.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1, // بطاقة واحدة في كل صف
            crossAxisSpacing: 16, // المسافة بين الأعمدة (غير مستخدمة هنا بسبب وجود بطاقة واحدة)
            mainAxisSpacing: 16, // المسافة بين الصفوف
            childAspectRatio: 1.2, // زيادة ارتفاع الكارد
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
                String createdAt = s.DateFormat('yyyy-MM-dd').format(course['created_at'].toDate());

                return _buildCourseCard(
                  context,
                  createdAt,
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
      String createdAt,
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
                height: 170,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.cairo(
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0096AB),
                        ),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 1),
                    Text(
                      details,
                      style: GoogleFonts.cairo(
                        textStyle: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 1),
                    Text(
                      createdAt,
                      style: GoogleFonts.cairo(
                        textStyle: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'المدرس: $teacher',
                      style: GoogleFonts.cairo(
                        textStyle: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      'الفئة: $category',
                      style: GoogleFonts.cairo(
                        textStyle: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFEFAC52),
                        ),
                      ),
                    ),
                    const SizedBox(height: 1),
                    rating > 0
                        ? Row(
                      children: [
                        _buildRatingStars(rating),
                        const SizedBox(width: 8),
                        Text(
                          rating.toStringAsFixed(1),
                          style: GoogleFonts.cairo(
                            textStyle: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
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
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingStars(double rating) {
    int fullStars = rating.floor();
    bool halfStar = (rating - fullStars) >= 0.5;

    List<Widget> stars = [];
    for (int i = 0; i < fullStars; i++) {
      stars.add(const Icon(Icons.star, color: Colors.amber, size: 14));
    }

    if (halfStar) {
      stars.add(const Icon(Icons.star_half, color: Colors.amber, size: 14));
    }

    while (stars.length < 5) {
      stars.add(const Icon(Icons.star_border, color: Colors.grey, size: 14));
    }

    return Row(children: stars);
  }
}
