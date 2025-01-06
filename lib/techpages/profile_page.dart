import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:graduation/techpages/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

    _fullNameController.text = userData?['fullName'] ?? 'Unknown';
    _emailController.text = userData?['email'] ?? 'No Email';
    _phoneController.text = userData?['phone'] ?? 'No Phone';
    _collegeController.text = userData?['college'] ?? 'Unknown';
    _degreeController.text = userData?['degree'] ?? 'Unknown';

    return userData ?? {};
  }

  void _saveChanges() {
    // منطق لحفظ التعديلات، مثل تحديث قاعدة البيانات أو SharedPreferences
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Changes saved successfully!')),
    );
  }

  Future<void> _logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');  // حذف التوكن المخزن
    // فتح صفحة تسجيل الدخول
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginPage()), // تأكد من استبدال LoginPage باسم الصفحتك الفعلي
          (Route<dynamic> route) => false, // حذف جميع الصفحات السابقة من المكدس
    );
  }

  void _contactUs() {
    // منطق فتح صفحة الاتصال، يمكن تنفيذ صفحة جديدة أو عرض معلومات الاتصال
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Us'),
        content: const Text('For inquiries, please contact us at: support@example.com'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
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
          backgroundColor: const Color(0xFF0096AB),
          elevation: 4.0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          title: const Text(
            'Profile',
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
              child: Text('Error: ${snapshot.error}', style: TextStyle(color: Color(0xFF0096AB))),
            );
          }

          final userData = snapshot.data;

          if (userData == null) {
            return const Center(
              child: Text('No user data found.'),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                _buildProfileCard(
                  icon: Icons.person,
                  title: 'Full Name',
                  child: TextField(
                    controller: _fullNameController,
                    decoration: const InputDecoration(
                      hintText: 'Enter your full name',
                    ),
                  ),
                ),
                _buildProfileCard(
                  icon: Icons.email,
                  title: 'Email',
                  child: TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      hintText: 'Enter your email',
                    ),
                  ),
                ),
                _buildProfileCard(
                  icon: Icons.phone,
                  title: 'Phone',
                  child: TextField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      hintText: 'Enter your phone number',
                    ),
                  ),
                ),
                _buildProfileCard(
                  icon: Icons.lock,
                  title: 'Password',
                  child: TextField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      hintText: 'Enter your password',
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
                  ),
                ),
                _buildProfileCard(
                  icon: Icons.school,
                  title: 'College',
                  child: TextField(
                    controller: _collegeController,
                    decoration: const InputDecoration(
                      hintText: 'Enter your college',
                    ),
                  ),
                ),
                _buildProfileCard(
                  icon: Icons.grade,
                  title: 'Degree',
                  child: TextField(
                    controller: _degreeController,
                    decoration: const InputDecoration(
                      hintText: 'Enter your degree',
                    ),
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
                    'Save Changes',
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
                    'Contact Us',
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
                    'Logout',
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