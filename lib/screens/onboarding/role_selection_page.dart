// lib/screens/onboarding/role_selection_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/constants/colors.dart';
import '../../shared/widgets/gradient_button.dart';
import '../../providers/app_providers.dart';
import 'language_selection_page.dart';

class _Option {
  final String name;
  final String code;
  final IconData icon;
  const _Option(this.name, this.code, this.icon);
}

class RoleSelectionPage extends ConsumerWidget {
  static const routeName = '/role-selection';
  const RoleSelectionPage({super.key});

  final List<_Option> roles = const [
    _Option('Client', 'client', Icons.person_outline),
    _Option('Lawyer', 'lawyer', Icons.person_pin),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedRole = ref.watch(roleProvider);
    final roleNotifier = ref.read(roleProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Select Your Role', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'I am a',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 32),
              Wrap(
                spacing: 40,
                runSpacing: 24,
                alignment: WrapAlignment.center,
                children: roles.map((opt) {
                  final isSelected = selectedRole == opt.code;
                  return GestureDetector(
                    onTap: () => roleNotifier.setRole(opt.code),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: isSelected ? AppColors.primary : Colors.grey[200],
                          child: Icon(
                            opt.icon,
                            size: 36,
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          opt.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? AppColors.primary : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const Spacer(),
              selectedRole != null && selectedRole.isNotEmpty
                  ? GradientButton(
                text: 'Continue to Language Selection',
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    LanguageSelectionPage.routeName,
                  );
                },
                gradientColors: [AppColors.primary, AppColors.accent],
                height: 50,
              )
                  : Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'Continue to Language Selection',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
