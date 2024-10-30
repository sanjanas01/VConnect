import 'package:flutter/material.dart';
import 'community.dart';
class BottomNavigation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.home),
            onPressed: () {
              Navigator.pushNamed(context, '/about_us');
            },
          ),
          
          IconButton(
            icon: Icon(Icons.forum),
            onPressed: () {
              Navigator.pushNamed(context, '/community_forum');
            },
          ),

          // IconButton(
          //   icon: Icon(Icons.person_add),
          //   onPressed: () {
          //     Navigator.pushNamed(context, '/follow');
          //   },
          // ),
          
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {
              Navigator.pushNamed(context, '/myaccount');
            },
          ),
        ],
      ),
    );
  }
}