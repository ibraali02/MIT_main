import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'CurrentCourses_Page.dart';
import 'home_page.dart';
import 'saved_page.dart';
import 'profile_page.dart';

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  _NavigationPageState createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const CurrentCoursesPage(),
    const SavedPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              spreadRadius: 2,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF0096AB),
          unselectedItemColor: const Color(0xFFEFAC52),
          showUnselectedLabels: true,
          selectedFontSize: 14,
          unselectedFontSize: 12,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined, size: 28),
              activeIcon: Icon(Icons.home, size: 30),
              label: 'الرئيسية',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.class_outlined, size: 28),
              activeIcon: Icon(Icons.class_, size: 30),
              label: 'المستمرة',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bookmark_border, size: 28),
              activeIcon: Icon(Icons.bookmark, size: 30),
              label: 'المكتملة',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline, size: 28),
              activeIcon: Icon(Icons.person, size: 30),
              label: 'الملف الشخصي',
            ),
          ],
          selectedLabelStyle: GoogleFonts.cairo(),
          unselectedLabelStyle: GoogleFonts.cairo(),
        ),
      ),
    );
  }
}
