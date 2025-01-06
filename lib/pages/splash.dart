import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
      // إذا وجد 'token'
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const tech_navigation.NavigationPage()),
      );
    } else if (prefs.containsKey('user_document_id')) {
      // إذا وجد 'user_document_id'
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const user_navigation.NavigationPage()),
      );
    } else {
      // إذا لم يوجد أي منهما
      Future.delayed(const Duration(seconds: 5), () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const FirstOpen1()),
        );
      });
    }
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
