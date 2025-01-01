import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RatingsPage extends StatefulWidget {
  final String courseId;

  const RatingsPage({super.key, required this.courseId});

  @override
  _RatingsPageState createState() => _RatingsPageState();
}

class _RatingsPageState extends State<RatingsPage> {
  final TextEditingController commentController = TextEditingController();

  // تعريف المتغيرات الخاصة بالتقييمات
  double contentScore = 3.0;
  double explanationScore = 3.0;
  double materialScore = 3.0;
  double overallScore = 3.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Rating'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Content Score:'),
            Slider(
              value: contentScore,
              min: 1,
              max: 5,
              divisions: 4,
              label: contentScore.toString(),
              onChanged: (value) {
                setState(() {
                  contentScore = value;
                });
              },
            ),
            const SizedBox(height: 20),
            const Text('Explanation Score:'),
            Slider(
              value: explanationScore,
              min: 1,
              max: 5,
              divisions: 4,
              label: explanationScore.toString(),
              onChanged: (value) {
                setState(() {
                  explanationScore = value;
                });
              },
            ),
            const SizedBox(height: 20),
            const Text('Material Score:'),
            Slider(
              value: materialScore,
              min: 1,
              max: 5,
              divisions: 4,
              label: materialScore.toString(),
              onChanged: (value) {
                setState(() {
                  materialScore = value;
                });
              },
            ),
            const SizedBox(height: 20),
            const Text('Overall Score:'),
            Slider(
              value: overallScore,
              min: 1,
              max: 5,
              divisions: 4,
              label: overallScore.toString(),
              onChanged: (value) {
                setState(() {
                  overallScore = value;
                });
              },
            ),
            const SizedBox(height: 20),
            TextField(
              controller: commentController,
              decoration: const InputDecoration(labelText: 'Your Comment'),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _saveRating(context),
              child: const Text('Submit Rating'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveRating(BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.courseId)
          .collection('ratings')
          .add({
        'username': 'Anonymous',  // Example: Use a predefined username or login data
        'contentScore': contentScore,
        'explanationScore': explanationScore,
        'materialScore': materialScore,
        'overallScore': overallScore,
        'comment': commentController.text,
        'createdAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rating submitted successfully')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving rating: $e')),
      );
    }
  }
}
