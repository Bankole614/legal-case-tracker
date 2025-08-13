import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../screens/auth/login_page.dart';
import '../screens/home/home_page.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../shared/constants/colors.dart';
import '../stores/auth_store.dart';

class SplashScreen extends ConsumerStatefulWidget {
  static const routeName = '/';

  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final seenOnboarding = await _storage.read(key: 'seenOnboarding');
    final token = await _storage.read(key: 'auth_token');

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    if (seenOnboarding != 'true') {
      Navigator.pushReplacementNamed(context, OnboardingScreen.routeName);
    } else if (token != null) {
      try {
        await ref.read(authStoreProvider.notifier).initializeFromToken(token);
        final authState = ref.read(authStoreProvider);

        if (authState.isAuthenticated) {
          Navigator.pushReplacementNamed(context, HomePage.routeName);
        } else {
          Navigator.pushReplacementNamed(context, LoginPage.routeName);
        }
      } catch (e) {
        // If token is invalid, go to login
        Navigator.pushReplacementNamed(context, LoginPage.routeName);
      }
    } else {
      Navigator.pushReplacementNamed(context, LoginPage.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.gavel, size: 80, color: AppColors.primary),
            const SizedBox(height: 16),
            Text(
              'RightNow',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}