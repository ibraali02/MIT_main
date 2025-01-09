import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';  // For Clipboard functionality

class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  _UserListPageState createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  String filterType = 'all';

  Future<void> _acceptUser(BuildContext context, String userId, String email, String password) async {
    try {
      // Accept the user
      await FirebaseFirestore.instance.collection('teacher_requests').doc(userId).update({
        'accepted': true,
      });

      // Copy the email and password to clipboard
      await Clipboard.setData(ClipboardData(text: '$email\n$password'));

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

  // Function to delete a password recovery request
  Future<void> _deletePasswordRecoveryRequest(BuildContext context, String requestId) async {
    try {
      await FirebaseFirestore.instance.collection('password_recovery_requests').doc(requestId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حذف طلب استعادة كلمة المرور بنجاح')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في حذف الطلب: $e')),
      );
    }
  }

  // Function to copy email to clipboard
  Future<void> _copyEmailToClipboard(String email) async {
    await Clipboard.setData(ClipboardData(text: email));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم نسخ البريد الإلكتروني إلى الحافظة')),
    );
  }

  // Function to show accept dialog
  Future<void> _showAcceptDialog(BuildContext context, var user) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('موافقة على المستخدم', style: GoogleFonts.cairo()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'هل ترغب في قبول المستخدم ${user['fullName']}؟\nالبريد الإلكتروني: ${user['email']}\nالرمز: ${user['password']}',
                style: GoogleFonts.cairo(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await _acceptUser(context, user.id, user['email'], user['password']);
                Navigator.pop(context);
              },
              child: Text('قبول', style: GoogleFonts.cairo()),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('إلغاء', style: GoogleFonts.cairo()),
            ),
          ],
        );
      },
    );
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
                  const SizedBox(width: 10),
                  _buildFilterButton('طلبات نسيان الرمز', 'password_recovery_requests'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: filterType == 'students'
                  ? FirebaseFirestore.instance.collection('students').snapshots()
                  : filterType == 'password_recovery_requests'
                  ? FirebaseFirestore.instance.collection('password_recovery_requests').snapshots()
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
                } else if (filterType == 'password_recovery_requests') {
                  return _buildPasswordRecoveryList(data);
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
              'البريد الإلكتروني: ${user['email']}\nالكلية: ${user['college']}\nالشهادة: ${user['degree']}\nرقم الهاتف: ${user['phone']}\nالرمز: ${user['password']}',
              style: GoogleFonts.cairo(),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isAccepted)
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: () async {
                      await _showAcceptDialog(context, user);
                    },
                  ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () async {
                    await _rejectUser(context, user.id);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPasswordRecoveryList(List<DocumentSnapshot> data) {
    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        var user = data[index];
        return Card(
          margin: const EdgeInsets.all(8.0),
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: ListTile(
            title: Text(
              user['full_name'],
              style: GoogleFonts.cairo(),
            ),
            subtitle: Text(
              'البريد الإلكتروني: ${user['email']}\nرقم الهاتف: ${user['phone']}\nالمدينة: ${user['city']}\nالجنس: ${user['gender']}\nرقم التسجيل: ${user['registration_number']}',
              style: GoogleFonts.cairo(),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.copy, color: Colors.blue),
                  onPressed: () {
                    _copyEmailToClipboard(user['email']);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    await _deletePasswordRecoveryRequest(context, user.id);
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
