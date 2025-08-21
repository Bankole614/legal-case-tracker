import 'screens/home/case_create_page.dart';
import 'screens/home/case_list_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

import 'shared/constants/colors.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/auth/login_page.dart';
import 'screens/auth/signup_page.dart';
import 'screens/home/home_page.dart';
import 'screens/onboarding/language_selection_page.dart';
import 'screens/onboarding/role_selection_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final ThemeData rightNowTheme = ThemeData(
  appBarTheme: AppBarTheme(
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      centerTitle: true
  ),
  primaryColor: AppColors.primary,
  scaffoldBackgroundColor: AppColors.background,
  fontFamily: 'Manrope',
  textTheme: const TextTheme(
    bodyLarge: TextStyle(fontSize: 16, color: AppColors.textPrimary),
    bodyMedium: TextStyle(fontSize: 14, color: AppColors.textSecondary),
    titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: AppColors.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
    ),
  ),
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  const String geminiApiKey = 'AIzaSyDFQ3w26Zz_qR91E3-Uog9aG-nIb28uS3w';

  if (geminiApiKey.isEmpty) {
    throw Exception('Gemini API key is missing. Set it in main.dart');
  }

  Gemini.init(apiKey: geminiApiKey);

  runApp(const ProviderScope(child: RightNowApp()));
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
        '/add-case': (_) => const CaseCreatePage(),
        '/case-detail': (_) => const CaseListPage(), // view/edit a single case
      },
    );
  }
}
