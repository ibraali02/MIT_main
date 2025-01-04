import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  bool _isPasswordVisible = false; // للتحكم في إظهار/إخفاء كلمة المرور

  Future<Map<String, dynamic>>? _userDataFuture;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
    _fullNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _userDataFuture = _fetchUserProfile();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> _fetchUserProfile() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userToken = prefs.getString('token');

    if (userToken == null) {
      throw Exception("User token not found. Please log in again.");
    }

    final DocumentSnapshot<Map<String, dynamic>> userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userToken)
        .get();

    if (!userSnapshot.exists) {
      throw Exception("User data not found.");
    }

    final userData = userSnapshot.data();

    _usernameController.text = userData?['username'] ?? 'Unknown';
    _passwordController.text = userData?['password'] ?? '***';
    _fullNameController.text = userData?['full_name'] ?? 'Unknown';
    _emailController.text = userData?['email'] ?? 'No Email';
    _phoneController.text = userData?['phone'] ?? 'No Phone';

    return {
      'full_name': userData?['full_name'] ?? 'Unknown',
      'email': userData?['email'] ?? 'No Email',
      'phone': userData?['phone'] ?? 'No Phone',
      'username': userData?['username'] ?? 'unknown',
      'password': userData?['password'] ?? '***',
      'city': userData?['city'] ?? 'Unknown',
      'gender': userData?['gender'] ?? 'Unknown',
      'registrationNumber': userData?['registrationNumber'] ?? 'Unknown',
    };
  }

  void _saveChanges() {
    // منطق لحفظ التعديلات، مثل تحديث قاعدة البيانات أو SharedPreferences
    // يمكن هنا تحديث البيانات في Firestore أو غيرها
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Changes saved successfully!')),
    );
  }

  void _showContactUsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Contact Us'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'You can contact us at:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0096AB)),
              ),
              SizedBox(height: 20),
              Text(
                'Email: support@example.com',
                style: TextStyle(fontSize: 16, color: Color(0xFF4F4F4F)),
              ),
              SizedBox(height: 10),
              Text(
                'Phone: +1 234 567 890',
                style: TextStyle(fontSize: 16, color: Color(0xFF4F4F4F)),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // إغلاق الحوار
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
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
              child: Text(
                'No user data found.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0096AB)),
              ),
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
                  icon: Icons.account_circle,
                  title: 'Username',
                  child: TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      hintText: 'Enter your username',
                    ),
                  ),
                ),
                _buildProfileCard(
                  icon: Icons.lock,
                  title: 'Password',
                  child: TextField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible, // إخفاء/إظهار كلمة المرور
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
                  onPressed: _showContactUsDialog, // عرض الـ Dialog عند الضغط على الزر
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
                  child ??
                      const Text(
                        'N/A',
                        style: TextStyle(fontSize: 16, color: Color(0xFF4F4F4F)),
                      ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
