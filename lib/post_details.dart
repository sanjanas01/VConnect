import 'package:flutter/material.dart';

//import 'package:url_launcher/url_launcher.dart'; // Import url_launcher package
import 'post.dart';

class PostDetails extends StatelessWidget {
  final Post post;

  const PostDetails({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Post Details'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(post.imageUrl),
            SizedBox(height: 20),
            Text(
              'Posted by: ${post.authorName}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Skills Required: ${post.skills_req}',
              style: TextStyle(
                fontSize: 18,
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Launch the apply link when the button is pressed
                
              },
              child: Text('Apply now'),
            ),
          ],
        ),
      ),
    );
  }
}