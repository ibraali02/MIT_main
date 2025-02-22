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
      final userToken = prefs.getString('token');

      if (userToken == null) {
        throw Exception('User token not found in SharedPreferences.');
      }

      // Search for the document in the 'users' collection where the token matches the document ID.
      final userDoc = await FirebaseFirestore.instance
          .collection('teacher_requests')
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

      body: Column(
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
                  return const Center(child: Text('Error loading comments'));
                }

                final comments = snapshot.data!.docs;

                if (comments.isEmpty) {
                  return const Center(child: Text('No comments yet.'));
                }

                return ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final commentData = comments[index].data() as Map<String, dynamic>;
                    final commentText = commentData['comment'] ?? 'No comment text';
                    final userName = commentData['user_name'] ?? 'Anonymous';
                    final timestamp = commentData['timestamp'] as Timestamp?;
                    final formattedTime = timestamp != null
                        ? DateTime.fromMillisecondsSinceEpoch(
                      timestamp.millisecondsSinceEpoch,
                    ).toString()
                        : 'Unknown time';

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(
                          userName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0096AB), // Dark Green
                          ),
                        ),
                        subtitle: Text(commentText),
                        trailing: Text(
                          formattedTime.split('.')[0], // Displays formatted time without milliseconds.
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
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
                      hintText: 'Enter your comment...',
                      filled: true,
                      fillColor: Colors.grey[200], // Light background color for the text field
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _addComment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0096AB), // Dark Green
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Add',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addComment() async {
    final commentText = _commentController.text.trim();
    if (commentText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comment cannot be empty.')),
      );
      return;
    }

    if (_userName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch user name.')),
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
        const SnackBar(content: Text('Comment added successfully.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add comment: $e')),
      );
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}
