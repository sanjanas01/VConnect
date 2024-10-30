import 'package:flutter/material.dart';
//import 'package:url_launcher/url_launcher.dart'; // Import url_launcher package
import 'post.dart';
import 'post_details.dart';


class InternshipsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jobs',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: PinterestHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class PinterestHomePage extends StatefulWidget {
  @override
  _PinterestHomePageState createState() => _PinterestHomePageState();
}

class _PinterestHomePageState extends State<PinterestHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Jobs'),
      ),
      body: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PostDetails(post: posts[index]),
                ),
              );
            },
            child: Container(
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.network(posts[index].imageUrl),
                  SizedBox(height: 10),
                  Text(
                    posts[index].title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}


List<Post> posts = [
  Post(
    title: 'Google SDE\'24',
    imageUrl:
        'https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEj_1mcwZ8ewLcE6XEd9H2TDYxxG6urFjNVtyil4AwtTXU2WBt4tgWyEIeYeM9VMmqHJ2SZcUX25CNYu7V_uRxuYxk5iSj5MAa6OoernV_jRtq7Fhe-00-6dVXmtkIiIHD6ehD3_OOr2pk6z4xm19aD7Hpza3H0S4tDLkRLmV0glTtNzPuvMcXmyAHuz9apz/s1120/WhatsApp%20Image%202023-07-23%20at%208.41.39%20PM.jpeg',
    authorName: 'Shruti',
    skills_req: ['Java', 'Python'],
    applyLink: 'https://example.com/apply', // Provide actual application link here
  ),
  Post(
    title: 'Microsoft Data Scientist Role',
    imageUrl:
        'https://miro.medium.com/v2/resize:fit:1400/0*Kb_P1Ow4v6Sd9Fcv.jpg',
    authorName: 'Ajay Karthick',
    skills_req: ['Machine Learning', 'Data Analysis'],
    applyLink: 'https://example.com/apply', // Provide actual application link here
  ),
  Post(
    title: 'Amazon App Developer',
    imageUrl:
        'https://miro.medium.com/v2/resize:fit:1358/1*pmPI_u7oBbsAUSZuEWAY5Q.png',
    authorName: 'Dhruv Sharma',
    skills_req: ['Flutter', 'UI/UX Design'],
    applyLink: 'https://example.com/apply', // Provide actual application link here
  ),
  Post(
    title: 'DRDO Internship',
    imageUrl:
        'https://internguru.com/wp-content/uploads/2022/01/Internship-at-DRDO.jpg',
    authorName: 'Venkatesan',
    skills_req: ['Web Development', 'JavaScript'],
    applyLink: 'https://example.com/apply', // Provide actual application link here
  ),
];