import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentPreferencePage extends StatefulWidget {
  @override
  _StudentPreferencePageState createState() => _StudentPreferencePageState();
}

class _StudentPreferencePageState extends State<StudentPreferencePage> {
  final TextEditingController departmentController = TextEditingController();
  final TextEditingController yearController = TextEditingController();
  String? role;
  final TextEditingController skillsController = TextEditingController();
  final TextEditingController subjectsController = TextEditingController();

  Future<void> _submitData(BuildContext context) async {
    final department = departmentController.text;
    final year = yearController.text;

    // Prepare the data based on role
    Map<String, dynamic> studentData = {
      'department': department,
      'year': year,
      'role': role,
    };
    if (role == '1') {
      studentData.addAll({
        'skills': skillsController.text,
        'subjects': subjectsController.text,
      });
    }

    // Add the data to Firestore
    FirebaseFirestore.instance.collection('student_preferences').add(studentData).then((_) {
      // Navigate back to the home page after successful submission
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    }).catchError((error) {
      // Handle error if any
      print("Failed to add student preference: $error");
      // Show error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit preference. Please try again.'),
          duration: Duration(seconds: 3),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Preference'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Department Name:',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            TextFormField(
              controller: departmentController,
              decoration: InputDecoration(
                hintText: 'Enter your department',
              ),
            ),
            SizedBox(height: 20.0),
            Text(
              'Current Year:',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            TextFormField(
              controller: yearController,
              decoration: InputDecoration(
                hintText: 'Enter your current year',
              ),
            ),
            SizedBox(height: 20.0),
            Text(
              'What\'s Your Role?:',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            DropdownButtonFormField<String>(
              value: role,
              decoration: InputDecoration(labelText: 'Select your role'),
              items: [
                DropdownMenuItem<String>(
                  value: '1',
                  child: Text('I can contribute in solving doubts'),
                ),
                DropdownMenuItem<String>(
                  value: '2',
                  child: Text('I want to clear doubts'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  role = value;
                });
              },
            ),
            if (role == '1') ...[
              SizedBox(height: 20.0),
              Text(
                'What are your skills?',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: skillsController,
                decoration: InputDecoration(
                  hintText: 'Enter your skills',
                ),
              ),
              SizedBox(height: 20.0),
              Text(
                'What subjects are you proficient in?',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: subjectsController,
                decoration: InputDecoration(
                  hintText: 'Enter proficient subjects',
                ),
              ),
            ],
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () => _submitData(context),
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: Center(
        child: Text('Welcome to the Home Page!'),
      ),
    );
  }
}