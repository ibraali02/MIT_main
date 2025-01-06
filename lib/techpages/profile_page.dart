import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:graduation/techpages/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart'; // لإضافة الخطوط

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController _passwordController;
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _collegeController;
  late TextEditingController _degreeController;

  bool _isPasswordVisible = false; // للتحكم في إظهار/إخفاء كلمة المرور

  Future<Map<String, dynamic>>? _userDataFuture;

  @override
  void initState() {
    super.initState();
    _passwordController = TextEditingController();
    _fullNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _collegeController = TextEditingController();
    _degreeController = TextEditingController();

    _userDataFuture = _fetchUserProfile();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _collegeController.dispose();
    _degreeController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> _fetchUserProfile() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userToken = prefs.getString('token');

    if (userToken == null) {
      throw Exception("User token not found. Please log in again.");
    }

    final DocumentSnapshot<Map<String, dynamic>> userSnapshot = await FirebaseFirestore.instance
        .collection('teacher_requests')
        .doc(userToken) // استخدام معرّف المستخدم لجلب بيانات الطلب
        .get();

    if (!userSnapshot.exists) {
      throw Exception("User data not found.");
    }

    final userData = userSnapshot.data();

    _fullNameController.text = userData?['fullName'] ?? 'غير معروف';
    _emailController.text = userData?['email'] ?? 'لا يوجد بريد إلكتروني';
    _phoneController.text = userData?['phone'] ?? 'لا يوجد رقم هاتف';
    _collegeController.text = userData?['college'] ?? 'غير معروف';
    _degreeController.text = userData?['degree'] ?? 'غير معروف';

    return userData ?? {};
  }

  void _saveChanges() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم حفظ التغييرات بنجاح!')),
    );
  }

  Future<void> _logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');  // حذف التوكن المخزن
    // فتح صفحة تسجيل الدخول
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginPage()),
          (Route<dynamic> route) => false, // حذف جميع الصفحات السابقة من المكدس
    );
  }

  void _contactUs() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('اتصل بنا'),
        content: const Text('للاستفسارات، يرجى الاتصال بنا على: support@example.com'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70.0),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xFF0096AB),
          elevation: 4.0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          title: const Text(
            'الملف الشخصي',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
        ),
      ),
      backgroundColor: Colors.white,
      body: FutureBuilder<Map<String, dynamic>>(
        future: _userDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('خطأ: ${snapshot.error}', style: TextStyle(color: Color(0xFF0096AB))),
            );
          }

          final userData = snapshot.data;

          if (userData == null) {
            return const Center(
              child: Text('لا توجد بيانات للمستخدم.'),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                _buildProfileCard(
                  icon: Icons.person,
                  title: 'الاسم الكامل',
                  child: TextField(
                    controller: _fullNameController,
                    decoration: const InputDecoration(
                      hintText: 'أدخل اسمك الكامل',
                    ),
                    style: GoogleFonts.cairo(), // تطبيق الخط
                    textDirection: TextDirection.rtl, // جعل اتجاه الكتابة RTL
                  ),
                ),
                _buildProfileCard(
                  icon: Icons.email,
                  title: 'البريد الإلكتروني',
                  child: TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      hintText: 'أدخل بريدك الإلكتروني',
                    ),
                    style: GoogleFonts.cairo(),
                    textDirection: TextDirection.rtl,
                  ),
                ),
                _buildProfileCard(
                  icon: Icons.phone,
                  title: 'الهاتف',
                  child: TextField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      hintText: 'أدخل رقم هاتفك',
                    ),
                    style: GoogleFonts.cairo(),
                    textDirection: TextDirection.rtl,
                  ),
                ),
                _buildProfileCard(
                  icon: Icons.lock,
                  title: 'كلمة المرور',
                  child: TextField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      hintText: 'أدخل كلمة المرور',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                          color: Color(0xFF0096AB),
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    style: GoogleFonts.cairo(),
                    textDirection: TextDirection.rtl,
                  ),
                ),
                _buildProfileCard(
                  icon: Icons.school,
                  title: 'الكلية',
                  child: TextField(
                    controller: _collegeController,
                    decoration: const InputDecoration(
                      hintText: 'أدخل اسم الكلية',
                    ),
                    style: GoogleFonts.cairo(),
                    textDirection: TextDirection.rtl,
                  ),
                ),
                _buildProfileCard(
                  icon: Icons.grade,
                  title: 'الدرجة',
                  child: TextField(
                    controller: _degreeController,
                    decoration: const InputDecoration(
                      hintText: 'أدخل درجتك',
                    ),
                    style: GoogleFonts.cairo(),
                    textDirection: TextDirection.rtl,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEFAC52),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'حفظ التغييرات',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _contactUs,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0096AB),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'اتصل بنا',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _logout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'تسجيل الخروج',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileCard({required IconData icon, required String title, Widget? child}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      color: const Color(0xFFF2F2F2),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 30, color: const Color(0xFF0096AB)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: const Color(0xFF0096AB)),
                  ),
                  const SizedBox(height: 4),
                  child ?? const Text('N/A'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
