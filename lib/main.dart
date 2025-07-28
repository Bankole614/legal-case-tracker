import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/auth/login_page.dart';
import 'screens/auth/signup_page.dart';
import 'screens/home/home_page.dart';
import 'screens/onboarding/language_selection_page.dart';
import 'screens/onboarding/role_selection_page.dart';

void main() {
  runApp(ProviderScope(child: RightNowApp()));
}

class RightNowApp extends ConsumerWidget {
  const RightNowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'RightNow',
      theme: ThemeData(primarySwatch: Colors.blue, primaryColor: Colors.black),
      debugShowCheckedModeBanner: false,
      initialRoute: SplashScreen.routeName,
      routes: {
        SplashScreen.routeName: (_) => SplashScreen(),
        OnboardingScreen.routeName: (_) => OnboardingScreen(),
        LanguageSelectionPage.routeName: (_) => LanguageSelectionPage(),
        RoleSelectionPage.routeName: (_) => RoleSelectionPage(),
        LoginPage.routeName: (_) => LoginPage(),
        SignupPage.routeName: (_) => SignupPage(),
        HomePage.routeName: (_) => HomePage(),
      },
    );
  }
}