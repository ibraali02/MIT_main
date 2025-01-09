import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../PasswordRecoveryPage.dart';
import 'navigation_page.dart';
import 'student_data_entry.dart';

class SignUpStd extends StatefulWidget {
  const SignUpStd({super.key});

  @override
  _SignUpStdState createState() => _SignUpStdState();
}

class _SignUpStdState extends State<SignUpStd> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void loginUser() async {
    try {
      if (emailController.text.trim().isEmpty || passwordController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('يرجى ملء جميع الحقول')),
        );
        return;
      }

      var userQuerySnapshot = await _firestore
          .collection('students')
          .where('email', isEqualTo: emailController.text.trim())
          .get();

      if (userQuerySnapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لا يوجد مستخدم بهذا البريد الإلكتروني.')),
        );
        return;
      }

      var userData = userQuerySnapshot.docs.first.data();

      if (userData['password'] != passwordController.text.trim()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('كلمة المرور غير صحيحة.')),
        );
        return;
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_document_id', userQuerySnapshot.docs.first.id);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تسجيل الدخول بنجاح')),
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const NavigationPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Column(
          children: <Widget>[
            // Header with reduced AppBar size
            PreferredSize(
              preferredSize: const Size.fromHeight(100), // Set the height of the AppBar
              child: AppBar(
                automaticallyImplyLeading: false,
                backgroundColor: const Color(0xFF1C9AAA),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0),
                  ),
                ),
                centerTitle: true,
                title: Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: Text(
                    'تسجيل الدخول',
                    style: GoogleFonts.cairo(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            // Logo below the AppBar
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: <Widget>[
                    // Image at the top
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Image.asset(
                        'lib/images/mit.png',
                        height: 300, // Adjust the height for the logo
                      ),
                    ),
                    // Email input field
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'أدخل بريدك الإلكتروني',
                        labelStyle: GoogleFonts.cairo(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Password input field
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'أدخل كلمة المرور',
                        labelStyle: GoogleFonts.cairo(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.visibility),
                          onPressed: () {},
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Login button
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: 60,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0B6A6D),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                        onPressed: loginUser,
                        child: Text(
                          'تسجيل الدخول',
                          style: GoogleFonts.cairo(fontSize: 20, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const PasswordRecoveryPage()),
                        );
                      },
                      child: Text(
                        'نسيت كلمة المرور؟',
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                    // Sign up link
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const StudentDataEntry()),
                        );
                      },
                      child: Text(
                        'ليس لديك حساب؟ سجل الآن',
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                    // Forgot password link

                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
