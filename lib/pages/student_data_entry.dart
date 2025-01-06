import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart'; // استيراد SharedPreferences
import 'first_up.dart';

class StudentDataEntry extends StatefulWidget {
  const StudentDataEntry({super.key});

  @override
  _StudentDataEntryState createState() => _StudentDataEntryState();
}

class _StudentDataEntryState extends State<StudentDataEntry> {
  final _firestore = FirebaseFirestore.instance;

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _registrationNumberController = TextEditingController();
  String? _selectedCity;
  String? _selectedGender;

  Future<void> _registerUser() async {
    try {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Passwords do not match!')),
        );
        return;
      }

      if (_fullNameController.text.isEmpty ||
          _emailController.text.isEmpty ||
          _phoneController.text.isEmpty ||
          _registrationNumberController.text.isEmpty ||
          _selectedCity == null ||
          _selectedGender == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill in all fields!')),
        );
        return;
      }

      String registrationNumber = _registrationNumberController.text.isNotEmpty
          ? _registrationNumberController.text
          : 'REG${DateTime.now().millisecondsSinceEpoch}';

      // إضافة المستخدم إلى Firestore
      DocumentReference docRef = await _firestore.collection('students').add({
        'fullName': _fullNameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'registrationNumber': registrationNumber,
        'city': _selectedCity,
        'gender': _selectedGender,
        'password': _passwordController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      // حفظ documentId في SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_document_id', docRef.id);

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Congratulations!'),
            content: const Text('Your account has been created successfully!'),
            actions: [
              TextButton(
                child: const Text('Done'),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const FirstUpPage()),
                  );
                },
              ),
            ],
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Data Entry'),
        backgroundColor: const Color(0xFF0096AB),
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              _buildTextField(_fullNameController, 'Full Name'),
              const SizedBox(height: 20),
              _buildTextField(_emailController, 'Email'),
              const SizedBox(height: 20),
              _buildTextField(_phoneController, 'Phone Number'),
              const SizedBox(height: 20),
              _buildTextField(_registrationNumberController, 'Registration Number'),
              const SizedBox(height: 20),
              _buildDropdownField('City', ['Miserata', 'Benghazi', 'Tripoli'], (value) {
                setState(() {
                  _selectedCity = value;
                });
              }),
              const SizedBox(height: 20),
              _buildDropdownField('Gender', ['Male', 'Female'], (value) {
                setState(() {
                  _selectedGender = value;
                });
              }),
              const SizedBox(height: 20),
              _buildPasswordField(_passwordController, 'Password'),
              const SizedBox(height: 20),
              _buildPasswordField(_confirmPasswordController, 'Confirm Password'),
              const SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEFAC52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                onPressed: _registerUser,
                child: const Text(
                  'Create', // تغيير النص إلى "Create"
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: 'Enter $label',
          hintStyle: const TextStyle(color: Colors.grey),
          labelStyle: const TextStyle(color: Color(0xFF0096AB)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        ),
      ),
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String label) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: true,
        decoration: InputDecoration(
          labelText: label,
          hintText: 'Enter $label',
          hintStyle: const TextStyle(color: Colors.grey),
          labelStyle: const TextStyle(color: Color(0xFF0096AB)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        ),
      ),
    );
  }

  Widget _buildDropdownField(String label, List<String> items, ValueChanged<String?> onChanged) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          hintText: 'Select $label',
          hintStyle: const TextStyle(color: Colors.grey),
          labelStyle: const TextStyle(color: Color(0xFF0096AB)),
          border: InputBorder.none,
        ),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}