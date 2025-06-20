import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => Size.fromHeight(50.0);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Color(0xFF818FB4),
      title: Text(
        'VConnect',
        style: TextStyle(
          fontFamily: 'Gabriela-Regular',
          fontSize: 24.0,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            showMenu(
              context: context,
              position: RelativeRect.fromLTRB(1000.0, 45.0 + kToolbarHeight, 0.0, 0.0),
              items: [
                
                _buildPopupMenuItem(
                  context,
                  icon: Icons.people,
                  value: '/mentorship', 
                  text: 'People You May Like',
                ),
                _buildPopupMenuItem(
                  context,
                  icon: Icons.forum,
                  value: '/community_forum',
                  text: 'Community Forum',
                ),
                _buildPopupMenuItem(
                  context,
                  icon: Icons.work,
                  value: '/internship',
                  text: 'Internships',
                ),
                _buildPopupMenuItem(
                  context,
                  icon: Icons.event,
                  value: '/events', 
                  text: 'Events',
                ),
                _buildPopupMenuItem(
                  context,
                  icon: Icons.logout,
                  value: '/logout', 
                  text: 'Logout',
                ),
              ],
            ).then((value) {
              if (value != null) {
                _handleMenuSelection(context, value);
              }
            });
          },
        ),
      ],
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String text,
  }) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: Colors.black),
          SizedBox(width: 8.0),
          Text(text),
        ],
      ),
    );
  }

  void _handleMenuSelection(BuildContext context, String value) {
    Navigator.pushNamed(context, value);
  }
}