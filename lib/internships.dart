import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'post.dart';
import 'top.dart';
import 'package:intl/intl.dart';
import 'bottom.dart';

class InternshipsPage extends StatefulWidget {
  @override
  _InternshipsPageState createState() => _InternshipsPageState();
}

class _InternshipsPageState extends State<InternshipsPage> {
  String? userType;
  List<Post> posts = [];
  List<Post> filteredPosts = [];
  bool isLoading = true;
  User? _user;
  String selectedDate = '';
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  Future<void> _fetchUser() async {
    _user = FirebaseAuth.instance.currentUser;
    if (_user != null) {
      await _fetchUserType();
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchUserType() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(_user!.uid)
        .get();

    setState(() {
      userType = userDoc['userType'];
    });

    if (userType != null) {
      await _fetchPosts();
    }
  }

  Future<void> _fetchPosts() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('internships')
          .get();

      if (snapshot.docs.isEmpty) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      // Convert posts and sort by deadline
      setState(() {
        posts = snapshot.docs.map((doc) {
          return Post(
            companyName: doc['companyName'] ?? '',
            applyLink: doc['applyLink'] ?? '',
            authorName: doc['authorEmail'] ?? 'Unknown',
            deadline: (doc['deadline'] != null && doc['deadline'] is String)
                ? doc['deadline']
                : 'Not specified',
            internshipRole: doc['internshipRole'] ?? 'Not specified', // Fetch role
          );
        }).toList();

        // Convert deadline string to DateTime for sorting
        posts.sort((a, b) {
          DateTime dateA = DateFormat('dd-MM-yyyy').parse(a.deadline);
          DateTime dateB = DateFormat('dd-MM-yyyy').parse(b.deadline);
          return dateA.compareTo(dateB);
        });

        filteredPosts = posts; // Initialize filteredPosts with all posts
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching posts: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void _filterPosts(String query) {
    setState(() {
      searchQuery = query;
      filteredPosts = posts
          .where((post) => post.companyName.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> _addNewInternship() async {
    String companyName = '';
    String applyLink = '';
    String internshipRole = ''; // New variable for role
    TextEditingController dateController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New Internship'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) {
                  companyName = value;
                },
                decoration: InputDecoration(labelText: 'Company Name'),
              ),
              TextField(
                onChanged: (value) {
                  applyLink = value;
                },
                decoration: InputDecoration(labelText: 'Apply Link'),
              ),
              TextField(
                onChanged: (value) {
                  internshipRole = value; // Capture role input
                },
                decoration: InputDecoration(labelText: 'Internship Role'),
              ),
              TextField(
                controller: dateController,
                onTap: () async {
                  FocusScope.of(context).requestFocus(FocusNode());
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    String formattedDate = pickedDate.toIso8601String().split('T').first;
                    DateTime myDate = DateTime.parse(formattedDate); 
                    String cDate = DateFormat('dd-MM-yyyy').format(myDate);
                    setState(() {
                      selectedDate = cDate; 
                      dateController.text = cDate; 
                    });
                  }
                },
                readOnly: true,
                decoration: InputDecoration(
                  labelText: selectedDate.isEmpty ? 'Select Deadline' : selectedDate,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (companyName.isNotEmpty && applyLink.isNotEmpty && selectedDate.isNotEmpty && internshipRole.isNotEmpty) {
                  await FirebaseFirestore.instance.collection('internships').add({
                    'companyName': companyName,
                    'applyLink': applyLink,
                    'authorEmail': _user?.email,
                    'deadline': selectedDate,
                    'internshipRole': internshipRole, // Add role to Firestore
                  });
                  Navigator.of(context).pop();
                  _fetchPosts();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please fill all fields')));
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                onChanged: _filterPosts,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search, color: Colors.black),
                  hintText: 'Search...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : filteredPosts.isEmpty
                    ? Center(child: Text("No internships available."))
                    : ListView.builder(
                        itemCount: filteredPosts.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            child: Container(
                              padding: EdgeInsets.all(10),
                              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                              decoration: BoxDecoration(
                                color: Color.fromARGB(255, 216, 228, 243),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    filteredPosts[index].companyName,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    'Role: ${filteredPosts[index].internshipRole}', // Display role
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    'Uploaded by: ${filteredPosts[index].authorName}',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    'Deadline: ${filteredPosts[index].deadline}',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  SizedBox(height: 5),
                                  ElevatedButton(
                                    onPressed: () {
                                      if (filteredPosts[index].applyLink.isNotEmpty) {
                                        launch(filteredPosts[index].applyLink);
                                      }
                                    },
                                    child: Text('Apply Now', style: TextStyle(color: Color.fromARGB(255, 12, 93, 192))),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: userType == 'Alumni'
          ? FloatingActionButton(
              onPressed: _addNewInternship,
              child: Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: BottomNavigation(),
    );
  }
}
