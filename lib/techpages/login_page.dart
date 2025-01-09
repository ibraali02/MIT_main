import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../PasswordRecoveryPage.dart';
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
              const SnackBar(content: Text('تم تسجيل الدخول بنجاح!')),
            );

            // Navigate to NavigationPage
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const NavigationPage()),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('كلمة المرور غير صحيحة')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('المستخدم غير موجود أو غير مقبول')),
          );
        }
      } catch (e) {
        print('Error logging in: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('حدث خطأ أثناء تسجيل الدخول')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى ملء جميع الحقول')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // Ensures that the screen adjusts when the keyboard appears
      body: SingleChildScrollView( // Allows scrolling when the keyboard is visible
        child: Directionality(
          textDirection: TextDirection.rtl, // Set the text direction to RTL
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
                  Text(
                    'مرحبًا بك مرة أخرى، أستاذ',
                    style: GoogleFonts.cairo(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1C9AAA),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'إذا لم يكن لديك حساب كأستاذ، اضغط هنا.',
                    style: GoogleFonts.cairo(fontSize: 16, color: Colors.grey),
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
                    child: Text(
                      'طلب انشاء حساب',
                      style: GoogleFonts.cairo(color: const Color(0xFF1C9AAA)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'البريد الإلكتروني',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    style: GoogleFonts.cairo(),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'كلمة المرور',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    style: GoogleFonts.cairo(),
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
                    child: Text(
                      'تسجيل الدخول',
                      style: GoogleFonts.cairo(fontSize: 18, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      // Navigate to PasswordRecoveryPage when the user clicks "Forgot Password"
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PasswordRecoveryPage()),
                      );
                    },
                    child: Text(
                      'نسيت كلمة المرور؟',
                      style: GoogleFonts.cairo(
                        color: const Color(0xFF1C9AAA),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
