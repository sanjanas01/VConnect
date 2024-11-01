import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
      home: StoriesPage(),
    );
  }
}

class StoriesPage extends StatefulWidget {
  @override
  _StoriesPageState createState() => _StoriesPageState();
}

class _StoriesPageState extends State<StoriesPage> {
  final FirebaseStorage storage = FirebaseStorage.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> posts = [];
  User? currentUser;

  @override
  void initState() {
    super.initState();
    _fetchPosts();
    _fetchCurrentUser();
  }

  Future<void> _fetchPosts() async {
    try {
      QuerySnapshot querySnapshot = await firestore.collection('stories').get();
      setState(() {
        posts = querySnapshot.docs
            .map((doc) {
              var data = doc.data() as Map<String, dynamic>;
              data['id'] = doc.id; 
              return data;
            })
            .toList();
      });
    } catch (e) {
      print('Error fetching posts: $e');
    }
  }

  Future<void> _fetchCurrentUser() async {
    currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).get();
      if (userDoc.exists) {
        currentUser = FirebaseAuth.instance.currentUser;
      }
    }
    setState(() {});
  }

  Future<void> saveUserData(User user) async {
    final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);

    userDoc.set({
      'name': user.displayName,
      'email': user.email,
    }, SetOptions(merge: true));
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      String? heading = await _inputDialog(context, 'Enter a short heading');
      String? description = await _inputDialog(context, 'Enter a description'); // New input for description
      if (heading != null && description != null && currentUser != null) {
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).get();
        String username = userDoc.data()?['name'] ?? 'Anonymous';
        _uploadImage(File(pickedFile.path), heading, description, currentUser!.displayName ?? username);
      }
    }
  }

  Future<void> _uploadImage(File image, String heading, String description, String username) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref = storage.ref().child('images/$fileName.jpg');
      UploadTask uploadTask = ref.putFile(image);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      DocumentReference newPostRef = firestore.collection('stories').doc();
      await newPostRef.set({
        'imageUrl': downloadUrl,
        'heading': heading,
        'description': description, // Storing the description
        'username': username,
        'comments': [],
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

  void _showPostDetails(Map<String, dynamic> post) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PostDetailsPage(post: post, firestore: firestore, currentUser: currentUser)),
    );
  }

  Widget _buildPostWidget(Map<String, dynamic> post) {
    return GestureDetector(
      onTap: () => _showPostDetails(post),
      child: Card(
        color: Color.fromARGB(255, 216, 228, 243),
        margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
              child: Image.network(
                post['imageUrl'],
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                post['heading'],
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
              child: Text(
                'Posted by: ${post['username']}',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Success Stories'),
        actions: [
          Row(
            children: [
              Text('Create Post', style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: _pickImage,
              ),
              
            ],
          ),
        ],
      ),
      body: posts.isEmpty
          ? Center(child: Text("No stories found", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))
          : ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                return _buildPostWidget(posts[index]);
              },
            ),
    );
  }
}

class PostDetailsPage extends StatefulWidget {
  final Map<String, dynamic> post;
  final FirebaseFirestore firestore;
  final User? currentUser;

  PostDetailsPage({required this.post, required this.firestore, required this.currentUser});

  @override
  _PostDetailsPageState createState() => _PostDetailsPageState();
}

class _PostDetailsPageState extends State<PostDetailsPage> {
  TextEditingController _commentController = TextEditingController();

  Future<void> _addComment() async {
    if (_commentController.text.isNotEmpty && widget.currentUser != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(widget.currentUser!.uid).get();
      String username = userDoc.data()?['name'] ?? 'Anonymous';
      String comment = '$username: ${_commentController.text}';
      widget.post['comments'].add(comment);
      await widget.firestore.collection('stories').doc(widget.post['id']).update({'comments': widget.post['comments']});
      setState(() {
        _commentController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Post Details'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.network(
                  widget.post['imageUrl'],
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 10),
              Text(
                widget.post['heading'],
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                widget.post['description'],
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              SizedBox(height: 10),
              Text(
                'Posted by: ${widget.post['username']}',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              SizedBox(height: 10),
              Text(
                'Comments:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: widget.post['comments'].length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(widget.post['comments'][index]),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    labelText: 'Add a comment',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: _addComment,
                child: Text('Comment'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
