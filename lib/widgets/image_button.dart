import 'package:flutter/material.dart';

Widget buildImageButton(IconData icon, VoidCallback onPressed) {
  return Container(
    width: 60,
    height: 60,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: LinearGradient(
        colors: [Color(0x71A0FB), Color(0x2C36ED), Color(0x7170E7)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    child: IconButton(
      icon: Icon(icon, color: Colors.white),
      onPressed: onPressed,
    ),
  );
}
