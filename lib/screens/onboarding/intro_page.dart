import 'package:flutter/material.dart';

class IntroPage extends StatelessWidget {
  final String title;
  final String description;
  final IconData image;
  const IntroPage({required this.title, required this.description, required this.image});
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(image, size: 100, color: Colors.blue),
            SizedBox(height: 32),
            Text(title, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Text(description, textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}