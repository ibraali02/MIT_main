import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts package
import 'stutech.dart';

class FirstOpen1 extends StatelessWidget {
  const FirstOpen1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/images/Splash Screens1.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              bottom: 300,
              left: MediaQuery.of(context).size.width / 2 - 160,
              child: Text(
                'MIT منصة تعليم الكتروني',
                style: GoogleFonts.cairo( // Use the Cairo font from Google Fonts
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.cyan,
                ),
              ),
            ),
            Positioned(
              bottom: 50,
              left: MediaQuery.of(context).size.width / 2 - 30,
              child: CircleAvatar(
                radius: 30,
                backgroundColor: Colors.orange,
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const LoginPagee()),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
