import 'package:flutter/material.dart';
import 'bottom.dart';
import 'about.dart'; // Import the AboutUsPage

class InfoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Our App',
          style: TextStyle(backgroundColor: Color(0xFFFA870)),
        ),
        backgroundColor: Color(0xFFFA8072),
        elevation: 0.0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/lg4.png', height: 100.0, width: 300.0), // LG4 logo
              ],
            ),
            SizedBox(height: 50), // Add some vertical space
            Text(
              'About Us',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFA8072), // Set color to blue
              ),
            ),
            SizedBox(height: 10), // Add some vertical space
            Text(
              'Welcome to our app! This app is designed to help users connect and engage with their communities. Whether you are a student or an alumni, this app provides a platform for networking, sharing information, and collaborating on various projects. With features like community forums, hackathons, internships, and more, users can stay updated with the latest events and opportunities in their field. Our goal is to foster a vibrant and supportive community where users can learn, grow, and succeed together.',
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.black87, // Set color to black87
              ),
            ),
           
            SizedBox(height: 50), // Add some vertical space
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AboutUsPage()),
                  );
                },
                child: Text(
                  'See More',
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Color(0xFFFA8072), // Set color to blue
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigation(),
    );
  }
}