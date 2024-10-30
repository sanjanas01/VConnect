import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'top.dart';
import 'bottom.dart';
class CommunityPage extends StatefulWidget {
  @override
  _CommunityPageState createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late User? _user;
  List<String> _joinedGroups = [];
  List<String> _communityGroups = [
    'DSA',
    'OS',
    'CAO',
    'CVLA',
    'English',
    'DAA',
  ];

  @override
  void initState() {
    super.initState();
    _fetchUser();
    _fetchJoinedGroups();
  }

  Future<void> _fetchUser() async {
    _user = _auth.currentUser;
  }

  Future<void> _fetchJoinedGroups() async {
    if (_user != null) {
      final userData = await _firestore.collection('users').doc(_user!.uid).get();
      final data = userData.data();
      if (data != null && data.containsKey('joinedGroups')) {
        setState(() {
          _joinedGroups = List<String>.from(data['joinedGroups']);
        });
      } else {
        await _firestore.collection('users').doc(_user!.uid).set({
          'joinedGroups': _joinedGroups,
        }, SetOptions(merge: true));
      }
    }
  }

  Future<void> _joinGroup(String groupName) async {
    if (_user != null) {
      try {
        if (!_joinedGroups.contains(groupName)) {
          _joinedGroups.add(groupName);
          await _firestore.collection('users').doc(_user!.uid).update({
            'joinedGroups': _joinedGroups,
          });
          setState(() {});
        }
      } catch (e) {
        print('Error joining group: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      
      body: ListView.builder(
        itemCount: _communityGroups.length,
        itemBuilder: (context, index) {
          final groupName = _communityGroups[index];
          final isJoined = _joinedGroups.contains(groupName);
          return ListTile(
            title: Text(groupName),
            subtitle: Text(isJoined ? 'Joined' : 'Join'),
            trailing: ElevatedButton(
              onPressed: () => _joinGroup(groupName),
              child: Text(isJoined ? 'Joined' : 'Join'),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GroupPostsPage(groupName)),
              );
            },
          );
        },
      ),
      
     bottomNavigationBar: BottomNavigation(),
    );
  }
}

class GroupPostsPage extends StatefulWidget {
  final String groupName;

  GroupPostsPage(this.groupName);

  @override
  _GroupPostsPageState createState() => _GroupPostsPageState();
}

class _GroupPostsPageState extends State<GroupPostsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late User? _user;
  late TextEditingController _textController;
  List<DocumentSnapshot> _posts = [];

  @override
  void initState() {
    super.initState();
    _fetchUser();
    _fetchPosts();
    _textController = TextEditingController();
  }

  Future<void> _fetchUser() async {
    _user = _auth.currentUser;
  }

  Future<void> _fetchPosts() async {
    try {
      final querySnapshot = await _firestore.collection(widget.groupName).get();
      setState(() {
        _posts = querySnapshot.docs;
      });
    } catch (e) {
      print('Error fetching posts: $e');
    }
  }

  Future<void> _postMessage() async {
    if (_user != null) {
      final message = _textController.text;
      if (message.isNotEmpty) {
        try {
          await _firestore.collection(widget.groupName).add({
            'author': _user!.displayName ?? _user!.email,
            'message': message,
            'timestamp': Timestamp.now(),
          });
          _textController.clear();
          _fetchPosts();
        } catch (e) {
          print('Error posting message: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupName),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _posts.length,
              itemBuilder: (context, index) {
                final post = _posts[index].data() as Map<String, dynamic>;
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: ListTile(
                      title: Text(
                        post['author'],
                        style: TextStyle(fontSize: 16.0),
                      ),
                      subtitle: Text(
                        post['message'],
                        style: TextStyle(fontSize: 16.0),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PostDetailsPage(
                              postId: _posts[index].id,
                              groupName: widget.groupName,
                              author: post['author'],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(labelText: 'Enter your message'),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _postMessage,
                  child: Text('Post'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PostDetailsPage extends StatefulWidget {
  final String postId;
  final String groupName;
  final String author;

  PostDetailsPage({required this.postId, required this.groupName, required this.author});

  @override
  _PostDetailsPageState createState() => _PostDetailsPageState();
}

class _PostDetailsPageState extends State<PostDetailsPage> {
  final TextEditingController _replyController = TextEditingController();
  List<Map<String, dynamic>> _replies = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reply Details'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _replies.length,
              itemBuilder: (context, index) {
                final reply = _replies[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: ListTile(
                      title: Text(
                        reply['author'],
                        style: TextStyle(fontSize: 16.0),
                      ),
                      subtitle: Text(
                        reply['message'],
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _replyController,
                    decoration: InputDecoration(labelText: 'Enter your reply'),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () async {
                    final replyMessage = _replyController.text;
                    if (replyMessage.isNotEmpty) {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        try {
                          await FirebaseFirestore.instance.collection(widget.groupName).doc(widget.postId).collection('replies').add({
                            'author': user.displayName ?? user.email,
                            'message': replyMessage,
                            'timestamp': Timestamp.now(),
                          });
                          setState(() {
                            _replyController.clear();
                          });
                          _fetchReplies();
                        } catch (e) {
                          print('Error posting reply: $e');
                        }
                      }
                    }
                  },
                  child: Text('Reply'),
                ),
              ],
            ),
          ),
        ],
      ),
      
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchReplies();
  }

  void _fetchReplies() {
    FirebaseFirestore.instance
      .collection(widget.groupName)
      .doc(widget.postId)
      .collection('replies')
      .orderBy('timestamp', descending: false)
      .get()
      .then((querySnapshot) {
        setState(() {
          _replies = querySnapshot.docs.map((doc) => doc.data()).toList();
        });
      });
  }
}