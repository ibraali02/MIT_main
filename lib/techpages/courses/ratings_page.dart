import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
      // إزالة الـ AppBar هنا
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
            return const Center(child: Text('No ratings available.'));
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
              final comment = rating['comment'];

              return Card(
                margin: const EdgeInsets.all(8.0),
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                color: const Color(0xFFF2F2F2), // لون الخلفية الرمادي الفاتح
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16.0),
                  title: Text(
                    username,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0096AB), // الأزرق الفاتح
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // عرض النجوم لكل تقييم
                      const Text('Content Score:'),
                      _buildStars(contentScore),
                      const SizedBox(height: 5),
                      const Text('Explanation Score:'),
                      _buildStars(explanationScore),
                      const SizedBox(height: 5),
                      const Text('Material Score:'),
                      _buildStars(materialScore),
                      const SizedBox(height: 5),
                      const Text('Overall Score:'),
                      _buildStars(overallScore),
                      const SizedBox(height: 10),
                      Text(
                        comment,
                        style: const TextStyle(
                          color: Color(0xFF4F4F4F), // النص الرمادي
                        ),
                      ),
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
