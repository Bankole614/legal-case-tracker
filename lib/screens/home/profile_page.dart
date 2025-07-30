import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/constants/colors.dart';
import '../../shared/widgets/gradient_button.dart';
import '../../providers/app_providers.dart';

class ProfilePage extends ConsumerWidget {
  static const routeName = '/profile';

  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(roleProvider);
    final language = ref.watch(languageProvider);

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
              const Text(
                'User Profile',
                style: TextStyle(
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
                gradientColors: [AppColors.primary, AppColors.accent],
                height: 50,
              ),
              const SizedBox(height: 16),
              // Logout button with error color
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text('Logout', style: TextStyle(color: Colors.white)),
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