import 'package:flutter/material.dart';
import 'package:sls/about.dart';
import 'package:sls/community.dart';
<<<<<<< HEAD
import 'package:sls/events.dart';
=======
import 'package:sls/hackathons.dart';
>>>>>>> origin/master
import 'package:sls/internships.dart';
import 'package:sls/stories.dart';
import 'top.dart';
import 'bottom.dart';

class InfoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Image.asset(
                'assets/Heading.png',
                width: double.infinity,
                fit: BoxFit.cover, 
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 24.0),
                    Text(
                      'Don’t Miss Out!',
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 16.0),
                    Container(
                      height: 250.0,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: Image.asset('assets/dress1.png', fit: BoxFit.cover),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: Image.asset('assets/dress2.png', fit: BoxFit.cover),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: Image.asset('assets/dress3.png', fit: BoxFit.cover),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: Image.asset('assets/dress4.png', fit: BoxFit.cover),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: Image.asset('assets/dress5.png', fit: BoxFit.cover),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Discover Your Path!',
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildFeatureBox(
                          color: Color(0xFF81C784),
                          icon: Icons.school,
                          title: 'Mentorship',
                          subtitle: 'Learn from the Best Minds',
                          onTap: () {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(builder: (context) => MentorshipPage()),
                            // );
                          },
                        ),
                        _buildFeatureBox(
                          color: Color(0xFF64B5F6),
                          icon: Icons.work,
                          title: 'Internships',
                          subtitle: 'Kickstart Your Career Journey',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => InternshipsPage()),
                            );
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 8.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildFeatureBox(
                          color: Color.fromARGB(255, 206, 141, 175),
                          icon: Icons.forum,
                          title: 'Community Hub',
                          subtitle: 'Connect, Share & Grow',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => CommunityPage()),
                            );
                          },
                        ),
                        _buildFeatureBox(
                          color: Color(0xFF9575CD),
                          icon: Icons.emoji_events,
                          title: 'Get Involved',
                          subtitle: 'Challenge Yourself & Shine',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => HackathonsPage()),
                            );
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 8.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildFeatureBox(
                          color: Color(0xFFA1887F),
                          icon: Icons.star,
                          title: 'Success Stories',
                          subtitle: 'Fuel Your Ambition',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => StoriesPage()),
                            );
                          },
                        ),
                        _buildFeatureBox(
                          color: Color.fromARGB(255, 238, 166, 112),
                          icon: Icons.info,
                          title: 'About Us',
                          subtitle: 'Unveil Our Vision',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => AboutUsPage()),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigation(),
    );
  }

  Widget _buildFeatureBox({required Color color, required IconData icon, required String title, required String subtitle, required Function() onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 175,
        height: 160,
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 40.0,
              color: Colors.white,
            ),
            SizedBox(height: 8.0),
            Text(
              title,
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 4.0),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}