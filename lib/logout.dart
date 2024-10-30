import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login.dart';

class LogoutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    FirebaseAuth.instance.signOut();
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/login');
    });
    return Scaffold(
      backgroundColor: Colors.black, // Set background color to black
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sentiment_satisfied, // Use the smiley face icon
              size: 80, // Set the size of the icon
              color: Colors.white, // Set the color of the icon
            ),
            SizedBox(height: 20), // Add some space between the icon and the text
            Text(
              'Logged out successfully',
              style: TextStyle(
                fontSize: 26, // Set font size to 26
                fontFamily: 'Gabriela-Regular', // Set font family to Gabriela-Regular
                color: Colors.white, // Set text color to white
              ),
            ),
          ],
        ),
      ),
    );
  }
}
