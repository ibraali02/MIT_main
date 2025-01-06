import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class RatingsPage extends StatefulWidget {
  final String courseId;

  const RatingsPage({super.key, required this.courseId});

  @override
  _RatingsPageState createState() => _RatingsPageState();
}

class _RatingsPageState extends State<RatingsPage> {
  // دالة لعرض النجوم بناءً على التقييم
  Widget _buildStars(double rating) {
    List<Widget> stars = [];
    for (int i = 1; i <= 5; i++) {
      Icon icon;
      if (i <= rating) {
        icon = const Icon(
          Icons.star,
          color: Color(0xFF0096AB), // الأزرق الفاتح
        );
      } else if (i == rating + 0.5) {
        icon = const Icon(
          Icons.star_half,
          color: Color(0xFF0096AB),
        );
      } else {
        icon = const Icon(
          Icons.star_border,
          color: Color(0xFF0096AB),
        );
      }
      stars.add(icon);
    }
    return Row(children: stars);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('courses')
            .doc(widget.courseId)
            .collection('ratings')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('لا توجد تقييمات.'));
          }

          final ratings = snapshot.data!.docs;

          return ListView.builder(
            itemCount: ratings.length,
            itemBuilder: (context, index) {
              final rating = ratings[index];
              final username = rating['username'];
              final contentScore = rating['contentScore'];
              final explanationScore = rating['explanationScore'];
              final materialScore = rating['materialScore'];
              final overallScore = rating['overallScore'];

              return Card(
                margin: const EdgeInsets.all(8.0),
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                color: const Color(0xFFF2F2F2),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16.0),
                  title: Text(
                    username,
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0096AB),
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // عرض النجوم لكل تقييم
                      Text(
                        'تقييم المحتوى:',
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          color: const Color(0xFF4F4F4F),
                        ),
                      ),
                      _buildStars(contentScore),
                      const SizedBox(height: 5),
                      Text(
                        'تقييم الشرح:',
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          color: const Color(0xFF4F4F4F),
                        ),
                      ),
                      _buildStars(explanationScore),
                      const SizedBox(height: 5),
                      Text(
                        'تقييم المادة:',
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          color: const Color(0xFF4F4F4F),
                        ),
                      ),
                      _buildStars(materialScore),
                      const SizedBox(height: 5),
                      Text(
                        'التقييم العام:',
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          color: const Color(0xFF4F4F4F),
                        ),
                      ),
                      _buildStars(overallScore),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
