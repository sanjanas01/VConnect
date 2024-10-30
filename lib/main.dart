import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'login.dart';
import 'logout.dart';
import 'mydetails.dart';
import 'community.dart';
import 'info.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
  options: FirebaseOptions(
    appId: '1:25621128381:android:95887032e27934840243d4',
    apiKey: 'AIzaSyDhLQ9_vqtBLhIArwAuYlGDCE0_ra_7ZnE',
    projectId: 'crafted-hope',
    messagingSenderId: '1234567890',
    //measurementId: 'G-ABCDEFGH',
  ),
);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alumnate',
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
        // '/follow': (context) => UserProfilePage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
