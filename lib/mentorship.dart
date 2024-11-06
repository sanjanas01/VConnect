import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sls/bottom.dart';
import 'top.dart';
import 'mydetails.dart';  // Import account page

class MentorshipPage extends StatefulWidget {
  @override
  _MentorshipPageState createState() => _MentorshipPageState();
}

class _MentorshipPageState extends State<MentorshipPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? currentUserName;
  List<String>? currentUserSkills;
  String? currentUserBranch;
  List<String>? currentUserInterests;
  List<Map<String, dynamic>> similarUsers = [];
  List<Map<String, dynamic>> interestBasedUsers = [];
  List<Map<String, dynamic>> branchBasedUsers = [];
  List<Map<String, dynamic>> randomUsers = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await _firestore.collection('uservc').doc(user.uid).get();

        if (userDoc.exists) {
          setState(() {
            currentUserName = userDoc['name'];
            currentUserSkills = List<String>.from(userDoc['skills']);
            currentUserBranch = userDoc['branch'] ?? "";
            currentUserInterests = List<String>.from(userDoc['interests']);
          });

          await fetchSimilarUsers();
          await fetchInterestBasedUsers();
          await fetchBranchBasedUsers();
          await fetchRandomUsers();
        } else {
          print("User document does not exist");
        }
      } else {
        print("No user is currently logged in");
      }
    } catch (e) {
      print("Error fetching user data: $e");
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> fetchSimilarUsers() async {
    if (currentUserSkills != null && currentUserSkills!.isNotEmpty) {
      QuerySnapshot usersSnapshot = await _firestore.collection('uservc').get();
      List<Map<String, dynamic>> potentialUsers = [];

      for (var userDoc in usersSnapshot.docs) {
        if (userDoc.id != _auth.currentUser!.uid) {
          List<String> userSkills = List<String>.from(userDoc['skills']);
          if (userSkills.any((skill) => currentUserSkills!.contains(skill))) {
            potentialUsers.add({
              'uid': userDoc.id,
              'name': userDoc['name'],
              'skills': userDoc['skills'],
              'type': 'skills'
            });
          }
        }
      }

      if (potentialUsers.isNotEmpty) {
        setState(() {
          similarUsers = potentialUsers;
        });
      }
    }
  }

  Future<void> fetchInterestBasedUsers() async {
    if (currentUserInterests != null && currentUserInterests!.isNotEmpty) {
      QuerySnapshot usersSnapshot = await _firestore.collection('uservc').get();
      List<Map<String, dynamic>> potentialUsers = [];

      for (var userDoc in usersSnapshot.docs) {
        if (userDoc.id != _auth.currentUser!.uid) {
          List<String> userInterests = List<String>.from(userDoc['interests']);
          if (userInterests.any((interest) => currentUserInterests!.contains(interest))) {
            potentialUsers.add({
              'uid': userDoc.id,
              'name': userDoc['name'],
              'interests': userDoc['interests'],
              'type': 'interests'
            });
          }
        }
      }

      if (potentialUsers.isNotEmpty) {
        setState(() {
          interestBasedUsers = potentialUsers;
        });
      }
    }
  }

  Future<void> fetchBranchBasedUsers() async {
    if (currentUserBranch != null && currentUserBranch!.isNotEmpty) {
      QuerySnapshot usersSnapshot = await _firestore.collection('uservc').get();
      List<Map<String, dynamic>> potentialUsers = [];

      for (var userDoc in usersSnapshot.docs) {
        if (userDoc.id != _auth.currentUser!.uid && userDoc['branch'] == currentUserBranch) {
          potentialUsers.add({
            'uid': userDoc.id,
            'name': userDoc['name'],
            'branch': userDoc['branch'],
            'type': 'branch'
          });
        }
      }

      if (potentialUsers.isNotEmpty) {
        setState(() {
          branchBasedUsers = potentialUsers;
        });
      }
    }
  }

  Future<void> fetchRandomUsers() async {
    QuerySnapshot usersSnapshot = await _firestore.collection('uservc').get();
    List<Map<String, dynamic>> potentialUsers = [];

    for (var userDoc in usersSnapshot.docs) {
      if (userDoc.id != _auth.currentUser!.uid) {
        potentialUsers.add({
          'uid': userDoc.id,
          'name': userDoc['name'],
          'skills': userDoc['skills'],
          'interests': userDoc['interests'],
          'branch': userDoc['branch']
        });
      }
    }

    setState(() {
      randomUsers = (potentialUsers..shuffle()).take(3).toList();
    });
  }

  Future<void> sendFollowRequest(String uid) async {
  User? user = _auth.currentUser;
  if (user != null) {
    // Fetch the target user's name
    DocumentSnapshot targetUserDoc = await _firestore.collection('uservc').doc(uid).get();
    String targetUserName = targetUserDoc['name'];
    await _firestore.collection('uservc').doc(uid).collection('followRequests').doc(user.uid).set({
      'from': user.uid,
      'fromName': currentUserName, 
      'targetName': targetUserName, 
      'status': 'pending'
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Follow request sent to $targetUserName'))
    );
  }
}


  Future<void> handleRequestResponse(String fromUid, bool accept) async {
    User? user = _auth.currentUser;
    if (user != null) {
      // Remove the request from pending
      await _firestore.collection('uservc').doc(user.uid).collection('followRequests').doc(fromUid).delete();

      if (accept) {
        // Add the accepted follow relationship
        await _firestore.collection('uservc').doc(user.uid).collection('followers').doc(fromUid).set({'status': 'accepted'});
        await _firestore.collection('uservc').doc(fromUid).collection('following').doc(user.uid).set({'status': 'following'});

        // Update follower and following counts
        await _firestore.collection('uservc').doc(user.uid).update({
          'followerCount': FieldValue.increment(1)  // Increment follower count
        });
        await _firestore.collection('uservc').doc(fromUid).update({
          'followingCount': FieldValue.increment(1)  // Increment following count
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Name: $currentUserName',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Your Skills: ${currentUserSkills?.join(', ') ?? "No skills listed"}',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Your Interests: ${currentUserInterests?.join(', ') ?? "No interests listed"}',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Your Branch: ${currentUserBranch ?? "No branch listed"}',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 20),
                    buildUserSection('People Based on Similar Skills:', similarUsers),
                    SizedBox(height: 10),
                    buildUserSection('People Based on Similar Interests:', interestBasedUsers),
                    SizedBox(height: 10),
                    buildUserSection('People in Your Branch:', branchBasedUsers),
                    SizedBox(height: 10),
                    buildUserSection('Random Users:', randomUsers),
                  ],
                ),
              ),
            ),
    );
  }

  Widget buildUserSection(String title, List<Map<String, dynamic>> users) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        ...users.map((user) => _buildUserTile(user)).toList(),
      ],
    );
  }

  Widget _buildUserTile(Map<String, dynamic> user) {
  String subtitleText = '';
  if (user.containsKey('skills')) {
    subtitleText = 'Skills: ${user['skills'].join(', ')}';
  } else if (user.containsKey('interests')) {
    subtitleText = 'Interests: ${user['interests'].join(', ')}';
  } else if (user.containsKey('branch')) {
    subtitleText = 'Branch: ${user['branch']}';
  }

  return Card(
    elevation: 2,
    margin: const EdgeInsets.symmetric(vertical: 8.0),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Color.fromARGB(255, 117, 150, 241),
                child: Text(
                  user['name'][0].toUpperCase(),
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(width: 10),
              Expanded( // Wrap this column with Expanded to avoid overflow
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user['name'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        overflow: TextOverflow.ellipsis, // Prevent text overflow
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      subtitleText,
                      style: TextStyle(
                        fontSize: 14,
                        overflow: TextOverflow.ellipsis, // Prevent text overflow
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          StreamBuilder<DocumentSnapshot>(
            stream: _firestore
                .collection('uservc')
                .doc(user['uid'])
                .collection('following')
                .doc(_auth.currentUser!.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }

              bool isFollowing = snapshot.data?.exists ?? false;
              return Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    sendFollowRequest(user['uid']);
                  },
                  child: Text(isFollowing ? 'Following' : 'Follow'),
                ),
              );
            },
          ),
        ],
      ),
    ),
  );
}

}