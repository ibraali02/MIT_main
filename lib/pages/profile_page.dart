import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'courses/CompletedCoursesPage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Future<Map<String, dynamic>>? _userDataFuture;

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

    // Fetch user profile data
    final DocumentSnapshot<Map<String, dynamic>> userSnapshot = await FirebaseFirestore.instance
        .collection('students')
        .doc(userToken)
        .get();

    if (!userSnapshot.exists) {
      throw Exception("User data not found.");
    }

    final userData = userSnapshot.data();  // Directly get data from the snapshot

    // Return the data with proper default values
    return {
      'fullName': userData?['fullName'] ?? 'Unknown',
      'email': userData?['email'] ?? 'No Email',
      'city': userData?['city'] ?? 'Unknown City',
      'gender': userData?['gender'] ?? 'Unknown Gender',
      'phone': userData?['phone'] ?? 'No Phone',
      'registrationNumber': userData?['registrationNumber'] ?? 'N/A',
    };
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
        child: AppBar(
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
                _buildProfileCard(
                  icon: Icons.person,
                  title: 'Full Name',
                  value: userData['fullName'],
                ),
                _buildProfileCard(
                  icon: Icons.email,
                  title: 'Email',
                  value: userData['email'],
                ),
                _buildProfileCard(
                  icon: Icons.location_city,
                  title: 'City',
                  value: userData['city'],
                ),
                _buildProfileCard(
                  icon: Icons.transgender,
                  title: 'Gender',
                  value: userData['gender'],
                ),
                _buildProfileCard(
                  icon: Icons.phone,
                  title: 'Phone',
                  value: userData['phone'],
                ),
                _buildProfileCard(
                  icon: Icons.confirmation_number,
                  title: 'Registration Number',
                  value: userData['registrationNumber'],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _showContactDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEFAC52), // Use the second color here for the button
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

  Widget _buildProfileCard({required IconData icon, required String title, required String value}) {
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: const Color(0xFF0096AB)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(fontSize: 16, color: Color(0xFF4F4F4F)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showContactDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Contact Us',
            style: TextStyle(color: Color(0xFF0096AB)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.phone, color: Color(0xFF0096AB)),
                title: Text('Phone:', style: TextStyle(color: Color(0xFF0096AB))),
                subtitle: Text('+1234567890', style: TextStyle(color: Color(0xFFEFAC52))),
              ),
              ListTile(
                leading: Icon(Icons.email, color: Color(0xFF0096AB)),
                title: Text('Email:', style: TextStyle(color: Color(0xFF0096AB))),
                subtitle: Text('contact@domain.com', style: TextStyle(color: Color(0xFFEFAC52))),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Close',
                style: TextStyle(color: Color(0xFF0096AB)),
              ),
            ),
          ],
        );
      },
    );
  }
}
