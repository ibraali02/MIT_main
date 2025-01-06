import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
          const SnackBar(content: Text('كلمات المرور غير متطابقة!')),
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
          const SnackBar(content: Text('يرجى ملء جميع الحقول!')),
        );
        return;
      }

      // تحقق من صحة البريد الإلكتروني الجامعي
      String email = _emailController.text.trim();
      if (!email.endsWith('@it.misuratau.edu.ly')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('يجب أن يكون البريد الإلكتروني بريدًا جامعيًا')),
        );
        return;
      }

      String registrationNumber = _registrationNumberController.text.isNotEmpty
          ? _registrationNumberController.text
          : 'REG${DateTime.now().millisecondsSinceEpoch}';

      // إضافة البيانات إلى Firestore
      DocumentReference docRef = await _firestore.collection('students').add({
        'fullName': _fullNameController.text.trim(),
        'email': email,
        'phone': _phoneController.text.trim(),
        'registrationNumber': registrationNumber,
        'city': _selectedCity,
        'gender': _selectedGender,
        'password': _passwordController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      // حفظ الـ Document ID في SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_document_id', docRef.id);

      // عرض رسالة نجاح
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('تهانينا!', style: GoogleFonts.cairo()),
            content: Text('تم إنشاء حسابك بنجاح!', style: GoogleFonts.cairo()),
            actions: [
              TextButton(
                child: Text('تم', style: GoogleFonts.cairo()),
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
        SnackBar(content: Text('خطأ: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('إدخال بيانات الطالب', style: GoogleFonts.cairo()),
          backgroundColor: const Color(0xFF0096AB),
          foregroundColor: Colors.white,
        ),
        body: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                _buildTextField(_fullNameController, 'الاسم الكامل'),
                const SizedBox(height: 20),
                _buildTextField(_emailController, 'البريد الإلكتروني الجامعي'),
                const SizedBox(height: 20),
                _buildTextField(_phoneController, 'رقم الهاتف'),
                const SizedBox(height: 20),
                _buildTextField(_registrationNumberController, 'رقم التسجيل'),
                const SizedBox(height: 20),
                _buildDropdownField('المدينة', ['مصراتة', 'بنغازي', 'طرابلس'], (value) {
                  setState(() {
                    _selectedCity = value;
                  });
                }),
                const SizedBox(height: 20),
                _buildDropdownField('الجنس', ['ذكر', 'أنثى'], (value) {
                  setState(() {
                    _selectedGender = value;
                  });
                }),
                const SizedBox(height: 20),
                _buildPasswordField(_passwordController, 'كلمة المرور'),
                const SizedBox(height: 20),
                _buildPasswordField(_confirmPasswordController, 'تأكيد كلمة المرور'),
                const SizedBox(height: 40),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEFAC52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  onPressed: _registerUser,
                  child: Text(
                    'إنشاء',
                    style: GoogleFonts.cairo(fontSize: 20, color: Colors.white),
                  ),
                ),
              ],
            ),
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
        textAlign: TextAlign.right,
        decoration: InputDecoration(
          labelText: label,
          hintText: 'أدخل $label',
          hintStyle: GoogleFonts.cairo(color: Colors.grey),
          labelStyle: GoogleFonts.cairo(color: const Color(0xFF0096AB)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        ),
      ),
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String label) {
    return _buildTextField(controller, label);
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
          hintText: 'اختر $label',
          hintStyle: GoogleFonts.cairo(color: Colors.grey),
          labelStyle: GoogleFonts.cairo(color: const Color(0xFF0096AB)),
          border: InputBorder.none,
        ),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item, style: GoogleFonts.cairo()),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
