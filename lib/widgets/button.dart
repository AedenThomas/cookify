import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';

class ModernButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  ModernButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 0,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.4),
                    Colors.white.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      text,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.black54,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
