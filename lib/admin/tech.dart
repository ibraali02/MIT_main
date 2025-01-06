import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  _UserListPageState createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  String filterType = 'all'; // 'all', 'accepted', 'pending', 'students'

  Future<void> _deleteStudent(BuildContext context, String studentId) async {
    try {
      await FirebaseFirestore.instance.collection('students').doc(studentId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Student deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting student: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User List'),
        backgroundColor: const Color(0xFF0096AB),
        centerTitle: true,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: SizedBox(
              height: 70, // ارتفاع كافٍ للأزرار
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                children: [
                  _buildFilterButton('Accepted Users', 'accepted'),
                  const SizedBox(width: 10),
                  _buildFilterButton('Pending Users', 'pending'),
                  const SizedBox(width: 10),
                  _buildFilterButton('All Requests', 'all'),
                  const SizedBox(width: 10),
                  _buildFilterButton('Students', 'students'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: filterType == 'students'
                  ? FirebaseFirestore.instance.collection('students').snapshots()
                  : FirebaseFirestore.instance
                  .collection('teacher_requests')
                  .where('accepted', isEqualTo: filterType == 'all' ? null : filterType == 'accepted')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var data = snapshot.data!.docs;
                if (filterType == 'students') {
                  return _buildStudentList(data);
                } else {
                  return _buildUserList(data);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String label, String type) {
    return SizedBox(
      width: 120,
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            filterType = type;
          });
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: filterType == type ? const Color(0xFFEFAC52) : const Color(0xFF0096AB),
          padding: const EdgeInsets.symmetric(vertical: 15),
        ),
        child: Text(label),
      ),
    );
  }

  Widget _buildStudentList(List<DocumentSnapshot> data) {
    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        var student = data[index];
        return Card(
          margin: const EdgeInsets.all(8.0),
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: ListTile(
            title: Text(student['fullName']),
            subtitle: Text('Email: ${student['email']}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                await _deleteStudent(context, student.id);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserList(List<DocumentSnapshot> data) {
    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        var user = data[index];
        bool isAccepted = user['accepted'] ?? false;
        return Card(
          margin: const EdgeInsets.all(8.0),
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: ListTile(
            title: Text(user['fullName']),
            subtitle: Text('Email: ${user['email']}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isAccepted)
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: () {
                      // Accept user logic here
                    },
                  ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () {
                    // Reject user logic here
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
