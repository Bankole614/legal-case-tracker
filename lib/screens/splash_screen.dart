import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../shared/constants/colors.dart';
import 'auth/login_page.dart';
import 'home/home_page.dart';
import '../storage/token_storage.dart';
import '../stores/auth_store.dart';

class SplashScreen extends ConsumerStatefulWidget {
  static const routeName = '/';
  const SplashScreen({super.key});
  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _go();
  }

  Future<void> _go() async {
    await Future.delayed(const Duration(milliseconds: 700));
    final tokens = ref.read(tokenStorageProvider);
    final token = await tokens.readToken();
    if (token == null) {
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
      return;
    }
    try {
      await ref.read(authStoreProvider.notifier).initializeFromToken(token);
      final state = ref.read(authStoreProvider);
      if (!mounted) return;
      if (state.isAuthenticated) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
      }
    } catch (_) {
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.gavel, size: 80, color: AppColors.primary), const SizedBox(height: 12), Text('RightNow', style: TextStyle(fontSize: 28, color: AppColors.primary, fontWeight: FontWeight.bold))])));
  }
}
