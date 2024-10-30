import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => Size.fromHeight(50.0);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Color(0xFFFA8072), // Background color
      flexibleSpace: Stack(
        children: [
          Positioned(
            left: 30.0,
            top: 35.0,
            child: Image.asset(
              'assets/logo2.png',
              height: 60,
              width: 100,
            ),
          ),
          Positioned(
            top: 50.0,
            left: MediaQuery.of(context).size.width / 2 - 60,
            child: Text(
              'Alumnate',
              style: TextStyle(
                fontFamily: 'Gabriela-Regular',
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}