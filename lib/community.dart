import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'top.dart';
import 'bottom.dart';
import 'package:intl/intl.dart';

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
  List<String> _filteredCommunityGroups = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUser();
    _fetchJoinedGroups();
    _filteredCommunityGroups = _communityGroups;
    _searchController.addListener(_filterGroups);
  }

  void _filterGroups() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCommunityGroups = _communityGroups.where((group) {
        return group.toLowerCase().contains(query);
      }).toList();
    });
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

  void _handleGroupTap(String groupName) {
    if (_joinedGroups.contains(groupName)) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => GroupPostsPage(groupName)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You need to join the group first to view posts.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search groups',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: _filteredCommunityGroups.length,
              separatorBuilder: (context, index) => Divider(),
              itemBuilder: (context, index) {
                final groupName = _filteredCommunityGroups[index];
                final isJoined = _joinedGroups.contains(groupName);
                return Card(
                  elevation: 3,
                  color: Color.fromARGB(255, 216, 228, 243),
                  child: ListTile(
                    title: Text(
                      groupName,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(isJoined ? 'Joined' : 'Join'),
                    trailing: ElevatedButton(
                      onPressed: () => _joinGroup(groupName),
                      child: Text(isJoined ? 'Joined' : 'Join'),
                    ),
                    onTap: () => _handleGroupTap(groupName),
                  ),
                );
              },
            ),
          ),
        ],
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
  late TextEditingController _searchController;
  List<DocumentSnapshot> _posts = [];
  List<DocumentSnapshot> _filteredPosts = [];

  @override
  void initState() {
    super.initState();
    _fetchUser();
    _fetchPosts();
    _textController = TextEditingController();
    _searchController = TextEditingController();
    _searchController.addListener(_filterPosts);
  }

  Future<void> _fetchUser() async {
    _user = _auth.currentUser;
  }

  Future<void> _fetchPosts() async {
    try {
      final querySnapshot = await _firestore.collection(widget.groupName).orderBy('timestamp', descending: true).get();
      setState(() {
        _posts = querySnapshot.docs;
        _filteredPosts = _posts;
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

  void _filterPosts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredPosts = _posts.where((post) {
        final data = post.data() as Map<String, dynamic>;
        final message = data['message'].toString().toLowerCase();
        return message.contains(query);
      }).toList();
    });
  }

  String _formatTimestamp(Timestamp timestamp) {
    final dateTime = timestamp.toDate();
    return DateFormat.yMMMd().add_jm().format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupName),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search posts',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredPosts.length,
              itemBuilder: (context, index) {
                final post = _filteredPosts[index].data() as Map<String, dynamic>;
                final timestamp = post['timestamp'] as Timestamp;
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    elevation: 3,
                    color: Color.fromARGB(255, 216, 228, 243),
                    child: ListTile(
                      title: Text(
                        post['author'],
                        style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(post['message'], style: TextStyle(fontSize: 16.0)),
                          Text(_formatTimestamp(timestamp), style: TextStyle(fontSize: 12.0, color: Colors.grey)),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PostDetailsPage(
                              postId: _filteredPosts[index].id,
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
                    decoration: InputDecoration(
                      labelText: 'Enter your message',
                      border: OutlineInputBorder(),
                    ),
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
      bottomNavigationBar: BottomNavigation(),
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
  void initState() {
    super.initState();
    _fetchReplies();
  }

  Future<void> _fetchReplies() async {
    FirebaseFirestore.instance
      .collection(widget.groupName)
      .doc(widget.postId)
      .collection('replies')
      .orderBy('timestamp', descending: false)
      .get()
      .then((querySnapshot) {
        setState(() {
          _replies = querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
        });
      });
  }

  Future<void> _postReply() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final replyText = _replyController.text;
      if (replyText.isNotEmpty) {
        final newReply = {
          'author': user.displayName ?? user.email,
          'message': replyText,
          'timestamp': Timestamp.now(),
        };

        FirebaseFirestore.instance
          .collection(widget.groupName)
          .doc(widget.postId)
          .collection('replies')
          .add(newReply)
          .then((_) {
            setState(() {
              _replies.add(newReply);
              _replyController.clear();
            });
          });
      }
    }
  }

  String _formatTimestamp(Timestamp timestamp) {
    final dateTime = timestamp.toDate();
    return DateFormat.yMMMd().add_jm().format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Post by ${widget.author}'),
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
                  child: Card(
                    elevation: 3,
                    color: Color.fromARGB(255, 216, 228, 243),
                    child: ListTile(
                      title: Text(
                        reply['author'],
                        style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(reply['message'], style: TextStyle(fontSize: 16.0)),
                          Text(_formatTimestamp(reply['timestamp']), style: TextStyle(fontSize: 12.0, color: Colors.grey)),
                        ],
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
                    decoration: InputDecoration(
                      labelText: 'Enter your reply',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _postReply,
                  child: Text('Reply'),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigation(),
    );
  }
}