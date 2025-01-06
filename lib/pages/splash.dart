import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'first_open1.dart';
import 'package:graduation/techpages/navigation_page.dart' as tech_navigation;
import 'package:graduation/pages/navigation_page.dart' as user_navigation;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSharedPreferences();
  }

  Future<void> _checkSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey('token')) {
      // If 'token' exists, check if it exists in the 'users' collection in Firestore
      String token = prefs.getString('token')!;
      bool tokenExists = await _checkTokenInFirestore(token);

      if (tokenExists) {
        // Token is valid, navigate to tech navigation
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const tech_navigation.NavigationPage()),
        );
      } else {
        _navigateToFirstOpen();
      }
    } else if (prefs.containsKey('user_document_id')) {
      // If 'user_document_id' exists, check if it exists in the 'students' collection in Firestore
      String userDocumentId = prefs.getString('user_document_id')!;
      bool userDocumentExists = await _checkUserDocumentInFirestore(userDocumentId);

      if (userDocumentExists) {
        // User document ID is valid, navigate to user navigation
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const user_navigation.NavigationPage()),
        );
      } else {
        _navigateToFirstOpen();
      }
    } else {
      // If neither 'token' nor 'user_document_id' exists
      _navigateToFirstOpen();
    }
  }

  Future<bool> _checkTokenInFirestore(String token) async {
    try {
      var snapshot = await FirebaseFirestore.instance.collection('users').doc(token).get();
      return snapshot.exists;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _checkUserDocumentInFirestore(String userDocumentId) async {
    try {
      var snapshot = await FirebaseFirestore.instance.collection('students').doc(userDocumentId).get();
      return snapshot.exists;
    } catch (e) {
      return false;
    }
  }

  void _navigateToFirstOpen() {
    Future.delayed(const Duration(seconds: 5), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const FirstOpen1()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset('lib/images/mit.png'),
      ),
    );
  }
}
