import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

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
  List<String> postImageUrls = [];

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    try {
      QuerySnapshot querySnapshot = await firestore.collection('hacks').get();
      setState(() {
        postImageUrls = querySnapshot.docs.map((doc) => doc['imageUrl'] as String).toList();
      });
    } catch (e) {
      print('Error fetching posts: $e');
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _uploadImage(File(pickedFile.path));
    }
  }

  Future<void> _uploadImage(File image) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref = storage.ref().child('images/$fileName.jpg');
      UploadTask uploadTask = ref.putFile(image);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      await firestore.collection('hacks').add({'imageUrl': downloadUrl});
      _fetchPosts();
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  Widget _buildImageWidget(String imageUrl) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Image.network(
        imageUrl,
        width: MediaQuery.of(context).size.width * 0.8,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hackathons'),
      ),
      body: ListView(
        children: [
          SizedBox(height: 10),
          Column(
            children: postImageUrls.map((url) => _buildImageWidget(url)).toList(),
          ),
          SizedBox(height: 10),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickImage,
        child: Icon(Icons.add),
      ),
    );
  }
}
