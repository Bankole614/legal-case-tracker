// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

import 'shared/constants/colors.dart';
import 'providers/role_provider.dart';
import 'shared/widgets/role_guard.dart';

import 'screens/splash_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/onboarding/role_selection_page.dart';
import 'screens/auth/login_page.dart';
import 'screens/auth/signup_page.dart';
import 'screens/home/home_page.dart';
import 'screens/home/case_create_page.dart';
import 'screens/home/case_list_page.dart';
import 'screens/home/case_detail_page.dart';
import 'screens/home/lawyer_dashboard.dart';

final ThemeData rightNowTheme = ThemeData(
  appBarTheme: const AppBarTheme(
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    backgroundColor: AppColors.primary,
    centerTitle: true,
    actionsIconTheme: IconThemeData(color: Colors.white),
    iconTheme: IconThemeData(color: Colors.white),
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

  // TODO: move Gemini API key into .env and read it from there
  const String geminiApiKey = 'AIzaSyDFQ3w26Zz_qR91E3-Uog9aG-nIb28uS3w';

  if (geminiApiKey.isEmpty) {
    throw Exception('Gemini API key is missing. Set it in main.dart or .env');
  }

  Gemini.init(apiKey: geminiApiKey);

  runApp(const ProviderScope(child: RightNowApp()));
}

class RightNowApp extends ConsumerWidget {
  const RightNowApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'RightNow',
      theme: rightNowTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: SplashScreen.routeName,
      // Static routes (no args)
      routes: {
        SplashScreen.routeName: (_) => const SplashScreen(),
        OnboardingScreen.routeName: (_) => const OnboardingScreen(),
        RoleSelectionPage.routeName: (_) => const RoleSelectionPage(),
        LoginPage.routeName: (_) => const LoginPage(),
        SignupPage.routeName: (_) => const SignupPage(),
        HomePage.routeName: (_) => const HomePage(),
        CaseCreatePage.routeName: (_) => const CaseCreatePage(),
        CaseListPage.routeName: (_) => const CaseListPage(),
        LawyerDashboard.routeName: (_) => const RoleGuard(
          required: AppRole.lawyer,
          child: LawyerDashboard(),
        ),
      },
      // Handle routes that need arguments here (e.g. case detail)
      onGenerateRoute: (settings) {
        // Case detail expects a single string argument: the caseId
        if (settings.name == CaseDetailPage.routeName) {
          final args = settings.arguments;
          String? caseId;

          // support either passing a raw string or a map like { 'caseId': '...' }
          if (args is String) {
            caseId = args;
          } else if (args is Map && args['caseId'] is String) {
            caseId = args['caseId'] as String;
          }

          if (caseId == null || caseId.isEmpty) {
            // If we don't have a caseId we show a simple fallback page instead of crashing.
            return MaterialPageRoute(builder: (_) {
              return Scaffold(
                appBar: AppBar(title: const Text('Case not found')),
                body: const Center(child: Text('No case id provided')),
              );
            });
          }

          // Build the page with the supplied caseId
          return MaterialPageRoute(builder: (_) => CaseDetailPage(caseId: caseId!));
        }

        // Unknown route fallback
        return MaterialPageRoute(builder: (_) {
          return Scaffold(
            appBar: AppBar(title: const Text('Not found')),
            body: const Center(child: Text('Page not found')),
          );
        });
      },
    );
  }
}
