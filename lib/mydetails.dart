import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sls/top.dart';
import 'bottom.dart';
import 'logout.dart'; // Import logout.dart file

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase User Details',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyDetailsPage(),
    );
  }
}

class MyDetailsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(logoutButton: true), // Pass true to indicate the presence of a logout button
      body: FutureBuilder<User?>(
        future: FirebaseAuth.instance.authStateChanges().first,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('No user logged in'));
          } else {
            User? user = snapshot.data;
            final uid = user!.uid;
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
              builder:
                  (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data == null) {
                  return Center(child: Text('No user data found'));
                } else {
                  Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
                  return Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: CircleAvatar(
                            backgroundImage: AssetImage('assets/user_image.png'), // Provide a default user image
                            radius: 50,
                          ),
                        ),
                        SizedBox(height: 20),
                        Card(
                          elevation: 4,
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Name: ${data['name'] ?? "Not available"}',
                                  style: TextStyle(fontSize: 18.0),
                                ),
                                SizedBox(height: 10.0),
                                Text(
                                  'Email: ${user.email}',
                                  style: TextStyle(fontSize: 18.0),
                                ),
                                SizedBox(height: 10.0),
                                Text(
                                  'Phone: ${data['phone'] ?? "Not available"}',
                                  style: TextStyle(fontSize: 18.0),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
            );
          }
        },
      ),
      bottomNavigationBar: BottomNavigation(),
    );
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool logoutButton;

  const CustomAppBar({Key? key, required this.logoutButton}) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(50.0);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text('My Account'),
      actions: [
        if (logoutButton)
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => LogoutPage()));
            },
          ),
      ],
    );
  }
}