import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../techpages/navigation_page.dart';
import 'SignUpDialogPage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Function to log in the user
  void _login() async {
    String username = _usernameController.text;
    String password = _passwordController.text;

    if (username.isNotEmpty && password.isNotEmpty) {
      try {
        // Normalize the username to lowercase for case-insensitive comparison
        String normalizedUsername = username.toLowerCase();

        // Get user from Firestore based on the username and check if the user is accepted
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('teacher_requests')
            .where('email', isEqualTo: normalizedUsername)
            .where('accepted', isEqualTo: true) // Only fetch accepted users
            .get();

        if (snapshot.docs.isNotEmpty) {
          var userDoc = snapshot.docs[0]; // Get the first document
          String documentId = userDoc.id; // Get the document ID

          // Check if the password matches
          if (userDoc['password'] == password) {
            // Save document ID as token in SharedPreferences
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString('token', documentId);

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Login successful!')),
            );

            // Navigate to NavigationPage
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const NavigationPage()),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Invalid password')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User not found or not accepted')),
          );
        }
      } catch (e) {
        print('Error logging in: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error logging in')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // Ensures that the screen adjusts when the keyboard appears
      body: SingleChildScrollView( // Allows scrolling when the keyboard is visible
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Column(
              children: [
                const SizedBox(height: 40),

                // الشعار تحت الـ AppBar مباشرة
                const Image(
                  image: AssetImage('lib/images/mit.png'), // ضع مسار الشعار هنا
                  height: 300, // تحديد ارتفاع الشعار
                ),
                const SizedBox(height: 20), // المسافة بين الشعار والنص
                const Text(
                  'Welcome Back Teacher',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1C9AAA),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'If you don’t have an account as a teacher, press here.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to SignUpPage when the user presses "Press Here"
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SignUpPage()),
                    );
                  },
                  child: const Text(
                    'Press Here',
                    style: TextStyle(color: Color(0xFF1C9AAA)),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1C9AAA),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
