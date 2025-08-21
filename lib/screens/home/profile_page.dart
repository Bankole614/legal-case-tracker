import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/constants/colors.dart';
import '../../shared/widgets/gradient_button.dart';
import '../../providers/app_providers.dart';
import '../../stores/auth_store.dart';  // Import your auth store
import '../auth/login_page.dart';      // Import your login page

class ProfilePage extends ConsumerStatefulWidget { // Changed
  static const routeName = '/profile';

  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState(); // Changed
}

class _ProfilePageState extends ConsumerState<ProfilePage> { // Changed
  Future<void> _logout() async { // No longer needs context and ref as direct params
    // Access context and ref via 'this.context' and 'ref' (from ConsumerState)
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => const Center(child: CircularProgressIndicator()),
      );

      await ref.read(authStoreProvider.notifier).logout();

      if (!mounted) return; // 'mounted' is now available directly

      navigator.pushNamedAndRemoveUntil(
        LoginPage.routeName,
            (route) => false,
      );
    } catch (e) {
      if (!mounted) return; // 'mounted' is now available directly

      Navigator.of(context, rootNavigator: true).pop();

      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Logout failed: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  @override
  Widget build(BuildContext context) { // context is available from State
    final role = ref.watch(roleProvider);
    final language = ref.watch(languageProvider);
    final authState = ref.watch(authStoreProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Profile', style: TextStyle(color: Colors.white)),
        automaticallyImplyLeading: false,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: const AssetImage('assets/images/avatar_placeholder.png'),
                backgroundColor: AppColors.accent.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Text(
                // authState.user?.firstName ?? 'User',
                'User',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              Text(
                authState.user?.email ?? 'User Profile',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 32),
              _InfoRow(label: 'Role', value: role?.toUpperCase() ?? 'N/A'),
              const SizedBox(height: 16),
              _InfoRow(label: 'Language', value: language?.toUpperCase() ?? 'N/A'),
              const SizedBox(height: 24),
              GradientButton(
                text: 'Settings',
                onPressed: () {
                  Navigator.pushNamed(context, '/settings');
                },
                // gradientColors: [AppColors.primary, AppColors.accent],
                height: 50,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: authState.isLoading
                    ? null
                    : _logout,
                icon: const Icon(Icons.logout, color: Colors.white),
                label: authState.isLoading
                    ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Text('Logout', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$label:',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}