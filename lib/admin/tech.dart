import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  _UserListPageState createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  String filterType = 'all';

  Future<void> _acceptUser(BuildContext context, String userId) async {
    try {
      await FirebaseFirestore.instance.collection('teacher_requests').doc(userId).update({
        'accepted': true,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم قبول المستخدم بنجاح')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء قبول المستخدم: $e')),
      );
    }
  }

  Future<void> _rejectUser(BuildContext context, String userId) async {
    try {
      await FirebaseFirestore.instance.collection('teacher_requests').doc(userId).update({
        'accepted': false,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم رفض المستخدم بنجاح')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء رفض المستخدم: $e')),
      );
    }
  }

  Future<void> _deleteStudent(BuildContext context, String studentId) async {
    try {
      await FirebaseFirestore.instance.collection('students').doc(studentId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حذف الطالب بنجاح')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في حذف الطالب: $e')),
      );
    }
  }

  // Function to open PDF
  Future<void> _openPDF(String url) async {
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في فتح ملف PDF: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'قائمة المستخدمين',
          style: GoogleFonts.cairo(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF0096AB),
        centerTitle: true,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: SizedBox(
              height: 70,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                children: [
                  _buildFilterButton('المستخدمين المقبولين', 'accepted'),
                  const SizedBox(width: 10),
                  _buildFilterButton('المستخدمين المعلقين', 'pending'),
                  const SizedBox(width: 10),
                  _buildFilterButton('جميع الطلبات', 'all'),
                  const SizedBox(width: 10),
                  _buildFilterButton('الطلاب', 'students'),
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
        child: Text(
          label,
          style: GoogleFonts.cairo(),
        ),
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
            title: Text(
              student['fullName'],
              style: GoogleFonts.cairo(),
            ),
            subtitle: Text(
              'البريد الإلكتروني: ${student['email']}',
              style: GoogleFonts.cairo(),
            ),
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
            title: Text(
              user['fullName'],
              style: GoogleFonts.cairo(),
            ),
            subtitle: Text(
              'البريد الإلكتروني: ${user['email']}',
              style: GoogleFonts.cairo(),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isAccepted)
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: () async {
                      await _acceptUser(context, user.id);
                    },
                  ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () async {
                    await _rejectUser(context, user.id);
                  },
                ),
                if (filterType == 'pending') // Show PDF button for pending requests
                  IconButton(
                    icon: const Icon(Icons.picture_as_pdf, color: Colors.blue),
                    onPressed: () async {
                      String pdfUrl = user['cvUrl'] ?? ''; // Assume the PDF URL is stored in the 'pdfUrl' field
                      if (pdfUrl.isNotEmpty) {
                        await _openPDF(pdfUrl);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('رابط PDF غير موجود لهذا المستخدم')),
                        );
                      }
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
