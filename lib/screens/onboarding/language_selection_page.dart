import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/constants/colors.dart';
import '../../shared/widgets/gradient_button.dart';
import '../../providers/app_providers.dart';
import '../auth/signup_page.dart';

class _Option {
  final String name;
  final String code;
  final IconData icon;
  const _Option(this.name, this.code, this.icon);
}

class LanguageSelectionPage extends ConsumerWidget {
  static const routeName = '/language-selection';

  const LanguageSelectionPage({super.key});

  final List<_Option> languages = const [
    _Option('Yoruba', 'yoruba', Icons.language),
    _Option('Hausa', 'hausa', Icons.language),
    _Option('Igbo', 'igbo', Icons.language),
    _Option('Pidgin', 'pidgin', Icons.language),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedLanguage = ref.watch(languageProvider);
    final languageNotifier = ref.read(languageProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Select Language', style: TextStyle(color: Colors.white)),
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
                'Select Your Language',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 32),
              Wrap(
                spacing: 24,
                runSpacing: 24,
                alignment: WrapAlignment.center,
                children: languages.map((opt) {
                  final isSelected = selectedLanguage == opt.code;
                  return GestureDetector(
                    onTap: () => languageNotifier.setLanguage(opt.code),
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
                            fontSize: 16,
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
              selectedLanguage != null && selectedLanguage.isNotEmpty
              ? GradientButton(
                text: 'Get Started',
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    SignupPage.routeName,
                  );
                },
                gradient: [AppColors.primary, AppColors.accent],
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
                  'Get Started',
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
