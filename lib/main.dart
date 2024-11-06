import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sls/events.dart';
import 'package:sls/internships.dart';
import 'package:sls/mentorship.dart';
import 'login.dart';
import 'logout.dart';
import 'mydetails.dart';
import 'community.dart';
import 'info.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VConnect',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/about_us': (context) => InfoPage(),
        '/logout': (context) => LogoutPage(),
        '/login': (context) => LoginPage(),
        '/myaccount': (context) => MyDetailsPage(),
        '/community_forum': (context) => CommunityPage(),
        '/internship': (context) => InternshipsPage(),
        '/events': (context) => HackathonsPage(),
        '/mentorship': (context) => MentorshipPage(),

        // '/follow': (context) => UserProfilePage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}