import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'shared/constants/colors.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/auth/login_page.dart';
import 'screens/auth/signup_page.dart';
import 'screens/home/home_page.dart';
import 'screens/onboarding/language_selection_page.dart';
import 'screens/onboarding/role_selection_page.dart';

final ThemeData rightNowTheme = ThemeData(
  primaryColor: AppColors.primary,
  scaffoldBackgroundColor: AppColors.background,
  fontFamily: 'Manrope',
  textTheme: TextTheme(
    bodyLarge: TextStyle(fontSize: 16, color: AppColors.textPrimary),
    bodyMedium: TextStyle(fontSize: 14, color: AppColors.textSecondary),
    titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.white, backgroundColor: AppColors.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
    ),
  ),
);

void main() {
  runApp(ProviderScope(child: RightNowApp()));
}

class RightNowApp extends ConsumerWidget {
  const RightNowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'RightNow',
      theme: rightNowTheme,
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