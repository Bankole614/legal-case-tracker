import 'package:flutter/material.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../shared/constants/colors.dart';

class SplashScreen extends StatefulWidget {
  static const routeName = '/';

  const SplashScreen({super.key});
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, OnboardingScreen.routeName);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.gavel, size: 80, color: AppColors.primary),
            SizedBox(height: 16),
            Text('RightNow', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primary)),
          ],
        ),
      ),
    );
  }
}