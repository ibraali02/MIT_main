import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PasswordRecoveryPage extends StatelessWidget {
  const PasswordRecoveryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController fullNameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController registrationNumberController = TextEditingController();
    final TextEditingController cityController = TextEditingController();
    String gender = "ذكر"; // Default gender is male

    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    // Function to store data in Firestore
    void storeData() {
      if (fullNameController.text.trim().isEmpty ||
          emailController.text.trim().isEmpty ||
          phoneController.text.trim().isEmpty ||
          registrationNumberController.text.trim().isEmpty ||
          cityController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('يرجى ملء جميع الحقول')),
        );
        return;
      }

      // Store data in Firestore collection
      _firestore.collection('password_recovery_requests').add({
        'full_name': fullNameController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
        'registration_number': registrationNumberController.text.trim(),
        'city': cityController.text.trim(),
        'gender': gender,
        'timestamp': FieldValue.serverTimestamp(),
      }).then((value) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إرسال البيانات بنجاح')),
        );
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ: $error')),
        );
      });
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('استعادة كلمة المرور', style: GoogleFonts.cairo(color: Colors.white)),
          backgroundColor: const Color(0xFF1C9AAA),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: <Widget>[
                // Full Name input field
                TextField(
                  controller: fullNameController,
                  decoration: InputDecoration(
                    labelText: 'الاسم الكامل',
                    labelStyle: GoogleFonts.cairo(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                ),
                const SizedBox(height: 20),

                // University Email input field
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'البريد الإلكتروني الجامعي',
                    labelStyle: GoogleFonts.cairo(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                ),
                const SizedBox(height: 20),

                // Phone number input field
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    labelText: 'رقم الهاتف',
                    labelStyle: GoogleFonts.cairo(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                ),
                const SizedBox(height: 20),

                // Registration Number input field
                TextField(
                  controller: registrationNumberController,
                  decoration: InputDecoration(
                    labelText: 'رقم القيد او اذا كنت استاذ ضع 0',
                    labelStyle: GoogleFonts.cairo(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                ),
                const SizedBox(height: 20),

                // City input field
                TextField(
                  controller: cityController,
                  decoration: InputDecoration(
                    labelText: 'المدينة',
                    labelStyle: GoogleFonts.cairo(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                ),
                const SizedBox(height: 20),

                // Gender selection field
                DropdownButton<String>(
                  value: gender,
                  onChanged: (String? newValue) {
                    gender = newValue!;
                  },
                  items: <String>['ذكر', 'أنثى']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: GoogleFonts.cairo()),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Notification text
                Text(
                  'سيتم إرسال البيانات للتأكد من صحتها للدعم الفني، وسنرسل لك الرمز الخاص بكل على رقم الهاتف.',
                  style: GoogleFonts.cairo(fontSize: 14, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Submit data button
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
                    onPressed: storeData,
                    child: Text(
                      'إرسال البيانات',
                      style: GoogleFonts.cairo(fontSize: 20, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}