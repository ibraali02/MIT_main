import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CommentsPage extends StatefulWidget {
  final String courseId;

  const CommentsPage({super.key, required this.courseId});

  @override
  _CommentsPageState createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  final TextEditingController _commentController = TextEditingController();
  String? _userName; // Variable to store the fetched username.

  @override
  void initState() {
    super.initState();
    _fetchUserName(); // Fetch the username when the page initializes.
  }

  Future<void> _fetchUserName() async {
    try {
      // Retrieve the user token from SharedPreferences.
      final prefs = await SharedPreferences.getInstance();
      final userToken = prefs.getString('user_document_id');

      if (userToken == null) {
        throw Exception('User token not found in SharedPreferences.');
      }

      // Search for the document in the 'users' collection where the token matches the document ID.
      final userDoc = await FirebaseFirestore.instance
          .collection('students')
          .doc(userToken)
          .get();

      if (userDoc.exists) {
        // Extract the user name from the document.
        setState(() {
          _userName = userDoc.data()?['fullName'] ?? 'Unknown User';
        });
      } else {
        throw Exception('User document not found.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch user data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Directionality(
        textDirection: TextDirection.rtl, // Set RTL direction
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('courses')
                    .doc(widget.courseId)
                    .collection('comments')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Center(child: Text('حدث خطأ أثناء تحميل التعليقات'));
                  }

                  final comments = snapshot.data!.docs;

                  if (comments.isEmpty) {
                    return const Center(child: Text('لا توجد تعليقات بعد.'));
                  }

                  return ListView.builder(
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final commentData = comments[index].data() as Map<String, dynamic>;
                      final commentText = commentData['comment'] ?? 'لا توجد نصوص للتعليق';
                      final userName = commentData['user_name'] ?? 'مستخدم مجهول';
                      final timestamp = commentData['timestamp'] as Timestamp?;
                      final formattedTime = timestamp != null
                          ? DateTime.fromMillisecondsSinceEpoch(
                        timestamp.millisecondsSinceEpoch,
                      ).toString()
                          : 'وقت غير معروف';

                      return ListTile(
                        title: Text(
                          userName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0096AB),
                            fontFamily: 'Cairo', // Use Cairo font
                          ),
                        ),
                        subtitle: Text(
                          commentText,
                          style: const TextStyle(
                            color: Color(0xFF0096AB),
                            fontFamily: 'Cairo', // Use Cairo font
                          ),
                        ),
                        trailing: Text(
                          formattedTime.split('.')[0], // Displays formatted time without milliseconds.
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontFamily: 'Cairo', // Use Cairo font
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: 'أدخل تعليقك...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        hintStyle: const TextStyle(color: Color(0xFF0096AB), fontFamily: 'Cairo'), // Hint text color and font
                      ),
                      style: const TextStyle(fontFamily: 'Cairo'), // Use Cairo font for input text
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _addComment,
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(const Color(0xFFEFAC52)), // Button color
                    ),
                    child: const Text(
                      'إضافة',
                      style: TextStyle(color: Colors.white, fontFamily: 'Cairo'), // Text color and font
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

  Future<void> _addComment() async {
    final commentText = _commentController.text.trim();
    if (commentText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('التعليق لا يمكن أن يكون فارغًا.')),
      );
      return;
    }

    if (_userName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشل في جلب اسم المستخدم.')),
      );
      return;
    }

    try {
      final commentData = {
        'comment': commentText,
        'user_name': _userName,
        'timestamp': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.courseId)
          .collection('comments')
          .add(commentData);

      _commentController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إضافة التعليق بنجاح.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في إضافة التعليق: $e')),
      );
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}
