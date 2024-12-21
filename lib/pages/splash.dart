import 'package:flutter/material.dart';
import 'first_open1.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 5), _navigateToFirstOpen);
  }

  void _navigateToFirstOpen() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => FirstOpen1()),
    );
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