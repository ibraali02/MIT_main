import 'package:flutter/material.dart';

import 'stutech.dart';

class FirstOpen1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/images/first1.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [

            Positioned(
              bottom: 50,
              left: MediaQuery.of(context).size.width / 2 - 30,
              child: CircleAvatar(
                radius: 30,
                backgroundColor: Colors.orange,
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => LoginPage()),
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