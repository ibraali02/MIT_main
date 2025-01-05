import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:graduation/pages/home_page.dart';
import 'package:graduation/techpages/navigation_page.dart';
import 'package:graduation/pages/signupstd.dart';
import 'package:graduation/techpages/login_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'admin/tech.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Supabase
    await Supabase.initialize(
      url: 'https://cmyehnpzfghzktgvlbbu.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNteWVobnB6Zmdoemt0Z3ZsYmJ1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzUxNjkyNTAsImV4cCI6MjA1MDc0NTI1MH0.DbStCnXzbLug6--m7P2wUkofYRfFs0SLHBlbIlBuiKU',
    );
    print("Supabase initialized successfully");
  } catch (e) {
    print("Error initializing Supabase: $e");
  }

  try {
    // Initialize Firebase
    await Firebase.initializeApp();
    print("Firebase initialized successfully");
  } catch (e) {
    print("Error initializing Firebase: $e");
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Graduation App', // Set the app title
      theme: ThemeData(
        primarySwatch: Colors.blue, // Define a primary color for the app
      ),
      home: UserListPage(), // Set the home page to LoginPage
    );
  }
}