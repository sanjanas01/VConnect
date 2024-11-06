import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PendingRequestsPage extends StatefulWidget {
  @override
  _PendingRequestsPageState createState() => _PendingRequestsPageState();
}

class _PendingRequestsPageState extends State<PendingRequestsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> pendingRequests = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchPendingRequests();
  }

  Future<void> fetchPendingRequests() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        QuerySnapshot requestsSnapshot = await _firestore
            .collection('uservc')
            .doc(user.uid)
            .collection('followRequests')
            .where('status', isEqualTo: 'pending')
            .get();

        List<Map<String, dynamic>> requestData = [];
        for (var doc in requestsSnapshot.docs) {
          String fromUid = doc['from'];
          // Fetch sender details based on UID
          DocumentSnapshot senderSnapshot = await _firestore.collection('uservc').doc(fromUid).get();
          if (senderSnapshot.exists) {
            requestData.add({
              'fromUid': fromUid,
              'name': senderSnapshot['name'] ?? 'Unknown',
              'status': doc['status'],
            });
          }
        }

        setState(() {
          pendingRequests = requestData;
        });
      } catch (e) {
        print("Error fetching pending requests: $e");
      } finally {
        setState(() {
          loading = false;
        });
      }
    }
  }

  Future<void> handleRequestResponse(String fromUid, bool accept) async {
    User? user = _auth.currentUser;
    if (user != null) {
      // Remove the request from Firestore
      await _firestore.collection('uservc').doc(user.uid).collection('followRequests').doc(fromUid).delete();

      if (accept) {
        // Add the accepted follow relationship
        await _firestore.collection('uservc').doc(user.uid).collection('followers').doc(fromUid).set({'status': 'accepted'});
        await _firestore.collection('uservc').doc(fromUid).collection('following').doc(user.uid).set({'status': 'following'});

        // Update follower and following counts
        await _firestore.collection('uservc').doc(user.uid).update({
          'followerCount': FieldValue.increment(1)
        });
        await _firestore.collection('uservc').doc(fromUid).update({
          'followingCount': FieldValue.increment(1)
        });
      }

      // Remove request from the local list and show Snackbar
      setState(() {
        pendingRequests.removeWhere((request) => request['fromUid'] == fromUid);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(accept ? 'Request accepted' : 'Request ignored'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pending Requests')),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : pendingRequests.isEmpty
              ? Center(child: Text('No pending requests.'))
              : ListView.builder(
                  itemCount: pendingRequests.length,
                  itemBuilder: (context, index) {
                    String fromUid = pendingRequests[index]['fromUid'];
                    String name = pendingRequests[index]['name'];
                    return ListTile(
                      title: Text('Request from: $name'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton(
                            onPressed: () => handleRequestResponse(fromUid, true),
                            child: Text('Accept'),
                          ),
                          SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () => handleRequestResponse(fromUid, false),
                            child: Text('Ignore'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
