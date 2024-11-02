import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sls/top.dart';
import 'bottom.dart';

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
        primaryColor:  Color(0xFF64B5F6),
        scaffoldBackgroundColor:  Color(0xFF64B5F6),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.black),
          bodyMedium: TextStyle(color: Colors.black),
          titleMedium: TextStyle(fontFamily: 'Gabriela-Regular', color: Colors.blue), 
        ),
      ),
      home: MyDetailsPage(),
    );
  }
}

class MyDetailsPage extends StatefulWidget {
  @override
  _MyDetailsPageState createState() => _MyDetailsPageState();
}

class _MyDetailsPageState extends State<MyDetailsPage> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _loadUserData();
  }

  void _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final uid = user.uid;
      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('uservc').doc(uid).get();
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        setState(() {
          _nameController.text = data['name'] ?? '';
          _phoneController.text = data['phone'] ?? '';
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
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
              future: FirebaseFirestore.instance.collection('uservc').doc(uid).get(),
              builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data == null) {
                  return Center(child: Text('No user data found'));
                } else {
                  Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
                  _nameController.text = data['name'] ?? '';
                  _phoneController.text = data['phone'] ?? '';
                  return Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: AssetImage('assets/user_image.png'), // Updated user icon
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Edit Your Profile',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 20),
                        ListTile(
                          leading: Icon(Icons.person, color: Colors.blue), // Change to blue
                          title: Text(
                            'Name: ${_nameController.text}',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                        ListTile(
                          leading: Icon(Icons.email, color: Colors.blue), // Change to blue
                          title: Text(
                            'Email: ${user.email}',
                            style: TextStyle(fontSize: 18, fontFamily: 'Gabriela-Regular'),
                          ),
                        ),
                        ListTile(
                          leading: Icon(Icons.phone, color: Colors.blue), // Change to blue
                          title: Text(
                            'Phone: ${_phoneController.text}',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () async {
                            bool? result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditProfilePage(
                                  name: _nameController.text,
                                  phone: _phoneController.text,
                                ),
                              ),
                            );
                            if (result == true) {
                              _loadUserData();
                            }
                          },
                          icon: Icon(Icons.edit),
                          label: Text('Edit Profile'),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white, backgroundColor:  Color(0xFF64B5F6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
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

class EditProfilePage extends StatefulWidget {
  final String name;
  final String phone;

  EditProfilePage({
    required this.name,
    required this.phone,
  });

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _phoneController = TextEditingController(text: widget.phone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    _updateUserData();
                  },
                  child: Text('Save Changes'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor:  Color(0xFF64B5F6), // Change to blue
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateUserData() async {
    String newName = _nameController.text.trim();
    String newPhone = _phoneController.text.trim();

    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('uservc').doc(user.uid).update({
          'name': newName,
          'phone': newPhone,
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('User data updated successfully'),
          duration: Duration(seconds: 2),
        ));

        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('User not found'),
          duration: Duration(seconds: 2),
        ));
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to update user data: $error'),
        duration: Duration(seconds: 2),
      ));
    }
  }
}
