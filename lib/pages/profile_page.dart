import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:graduation/pages/signupstd.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'courses/CompletedCoursesPage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Future<Map<String, dynamic>>? _userDataFuture;
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _registrationNumberController = TextEditingController();
  String? _userDocumentId;

  @override
  void initState() {
    super.initState();
    _userDataFuture = _fetchUserProfile();
  }

  Future<Map<String, dynamic>> _fetchUserProfile() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userToken = prefs.getString('user_document_id');

    if (userToken == null) {
      throw Exception("User token not found. Please log in again.");
    }

    _userDocumentId = userToken;

    // Fetch user profile data
    final DocumentSnapshot<Map<String, dynamic>> userSnapshot = await FirebaseFirestore.instance
        .collection('students')
        .doc(userToken)
        .get();

    if (!userSnapshot.exists) {
      throw Exception("User data not found.");
    }

    final userData = userSnapshot.data();  // Directly get data from the snapshot

    // Set the text controllers with fetched data
    _fullNameController.text = userData?['fullName'] ?? '';
    _emailController.text = userData?['email'] ?? '';
    _cityController.text = userData?['city'] ?? '';
    _genderController.text = userData?['gender'] ?? '';
    _phoneController.text = userData?['phone'] ?? '';
    _registrationNumberController.text = userData?['registrationNumber'] ?? '';

    return userData!;
  }

  // Save profile changes
  Future<void> _saveProfileChanges() async {
    final updatedData = {
      'fullName': _fullNameController.text,
      'email': _emailController.text,
      'city': _cityController.text,
      'gender': _genderController.text,
      'phone': _phoneController.text,
      'registrationNumber': _registrationNumberController.text,
    };

    await FirebaseFirestore.instance.collection('students').doc(_userDocumentId).update(updatedData);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully!')),
    );
  }

  // Log out the user
  // Log out the user
  Future<void> _logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_document_id'); // حذف التوكن
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) =>SignUpStd()), // استبدل LoginPage بصفحة تسجيل الدخول الخاصة بك
    );
  }

  // Navigate to Completed Courses Page
  void _navigateToCompletedCourses() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CompletedCoursesPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(

        preferredSize: const Size.fromHeight(70.0),
        child: AppBar( automaticallyImplyLeading: false,
          backgroundColor: const Color(0xFF0096AB), // Color for AppBar
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
              color: Colors.white, // Set the text color to white
            ),
          ),
          centerTitle: true, // Ensures the title is centered
        ),
      ),
      backgroundColor: Colors.white, // Set background color to white
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
                _buildEditableCard(
                  icon: Icons.person,
                  title: 'Full Name',
                  controller: _fullNameController,
                  enabled: true, // Allow editing
                ),
                _buildEditableCard(
                  icon: Icons.email,
                  title: 'Email',
                  controller: _emailController,
                  enabled: true, // Allow editing
                ),
                _buildEditableCard(
                  icon: Icons.location_city,
                  title: 'City',
                  controller: _cityController,
                  enabled: true, // Allow editing
                ),
                _buildEditableCard(
                  icon: Icons.transgender,
                  title: 'Gender',
                  controller: _genderController,
                  enabled: true, // Allow editing
                ),
                _buildEditableCard(
                  icon: Icons.phone,
                  title: 'Phone',
                  controller: _phoneController,
                  enabled: true, // Allow editing
                ),
                _buildEditableCard(
                  icon: Icons.confirmation_number,
                  title: 'Registration Number',
                  controller: _registrationNumberController,
                  enabled: true, // Allow editing
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveProfileChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Set button color to blue
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
                  onPressed: _logout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Set button color to red
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
                ElevatedButton(
                  onPressed: _navigateToCompletedCourses,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEFAC52),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'View Completed Courses',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEditableCard({required IconData icon, required String title, required TextEditingController controller, bool enabled = false}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      color: const Color(0xFFF2F2F2), // Light gray background for cards
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 30, color: const Color(0xFF0096AB)), // Use the first color for icons
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: title,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                enabled: enabled, // Allow editing if enabled
              ),
            ),
          ],
        ),
      ),
    );
  }
}