import 'package:flutter/material.dart';
import 'stories.dart';
import 'hackathons.dart';
import 'internships.dart';
import 'bottom.dart';
import 'top.dart';

class AboutUsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
      ),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            TabBar(
              tabs: [
                Tab(text: 'Hackathons'),
                Tab(text: 'Stories'),
                
                Tab(text: 'Internships'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  
                  HackathonsPage(),
                  StoriesPage(),
                  InternshipsPage(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigation(),
    );
  }
}