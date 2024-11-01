import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:sls/bottom.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Firebase Image Upload',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HackathonsPage(),
    );
  }
}

class HackathonsPage extends StatefulWidget {
  @override
  _HackathonsPageState createState() => _HackathonsPageState();
}

class _HackathonsPageState extends State<HackathonsPage> {
  final FirebaseStorage storage = FirebaseStorage.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> posts = [];
  Map<String, List<Map<String, dynamic>>> groupedPosts = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  String formatMonthYear(DateTime date) {
    final monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${monthNames[date.month - 1]} ${date.year}';
  }

  String formatEventDate(DateTime date) {
    return DateFormat('MMMM d, yyyy').format(date);
  }

  Future<void> _fetchPosts() async {
    setState(() {
      _isLoading = true;
      groupedPosts.clear();
    });
    print('Fetching posts from Firestore...');
    try {
      QuerySnapshot querySnapshot = await firestore.collection('hacks').orderBy('eventDate').get();
      print('Fetched ${querySnapshot.docs.length} documents.');

      for (var doc in querySnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        DateTime eventDate = DateTime.parse(data['eventDate']);
        String monthYear = formatMonthYear(eventDate);

        if (!groupedPosts.containsKey(monthYear)) {
          groupedPosts[monthYear] = [];
        }
        groupedPosts[monthYear]!.add({
          ...data,
          'eventDate': eventDate,
        });
      }

      setState(() {
        _isLoading = false;
      });
      print('Posts have been grouped by month and year.');
    } catch (e) {
      print('Error fetching posts: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      String? description = await _inputDialog(context, 'Enter a short description');
      String? contactNumber = await _inputDialog(context, 'Enter a contact number');
      String? eventDate = await _inputDialog(context, 'Enter the event date (YYYY-MM-DD)');
      if (description != null && contactNumber != null && eventDate != null) {
        _uploadImage(File(pickedFile.path), description, contactNumber, eventDate);
      }
    }
  }

  Future<void> _uploadImage(File image, String description, String contactNumber, String eventDate) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref = storage.ref().child('images/$fileName.jpg');
      UploadTask uploadTask = ref.putFile(image);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      print('Uploaded image URL: $downloadUrl');
      await firestore.collection('hacks').add({
        'imageUrl': downloadUrl,
        'description': description,
        'contactNumber': contactNumber,
        'eventDate': eventDate,
      });
      _fetchPosts();
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  Future<String?> _inputDialog(BuildContext context, String hint) {
    TextEditingController controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(hint),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: hint),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(controller.text);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildImageWidget(Map<String, dynamic> post) {
    return GestureDetector(
      onTap: () => _showPostDetails(post),
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 8.0),
        elevation: 4,
        child: Column(
          children: [
            Image.network(
              post['imageUrl'],
              width: MediaQuery.of(context).size.width * 0.9,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Event Date: ${formatEventDate(post['eventDate'])}',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPostDetails(Map<String, dynamic> post) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Event Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(post['imageUrl']),
              SizedBox(height: 10),
              Text('Description: ${post['description']}'),
              SizedBox(height: 10),
              Text('Contact: ${post['contactNumber']}'),
              SizedBox(height: 10),
              Text('Event Date: ${formatEventDate(post['eventDate'])}'), // Display formatted event date
            ],
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              onPressed: () => _makePhoneCall(post['contactNumber']),
              child: Text('Call'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launch(launchUri.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hackathons'),
        actions: [
          Row(
            children: [
              Text('Post an Event', style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: _pickImage,
              ),
              
            ],
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: groupedPosts.length,
              itemBuilder: (context, index) {
                String monthYear = groupedPosts.keys.elementAt(index);
                List<Map<String, dynamic>> postsForMonth = groupedPosts[monthYear]!;

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                        decoration: BoxDecoration(
                          color: Color(0xFF818FB4),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          formatMonthYear(postsForMonth[0]['eventDate']), // Use the date from the first post of the month
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      ...postsForMonth.map((post) => _buildImageWidget(post)).toList(),
                    ],
                  ),
                );
              },
            ),
            bottomNavigationBar: BottomNavigation(),
    );

  }
}
