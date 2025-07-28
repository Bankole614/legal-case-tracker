// [1] language_selection_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_providers.dart';
import '../auth/login_page.dart';
import '../auth/signup_page.dart'; // Assuming languageProvider is here

// Define the _Option class
class _Option {
  final String name;
  final String code;
  final IconData icon; // Or String for image path, etc.

  _Option(this.name, this.code, this.icon);
}

class LanguageSelectionPage extends ConsumerWidget {
  static const String routeName = '/language-selection';
  // Now the type _Option is known
  final List<_Option> languages = [
    _Option('Yoruba', 'yoruba', Icons.language),
    _Option('Hausa', 'hausa', Icons.language),
    _Option('Igbo', 'igbo', Icons.language),
    _Option('Pidgin', 'pidgin', Icons.language),
  ];

  LanguageSelectionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedLanguage = ref.watch(languageProvider);
    final languageNotifier = ref.read(languageProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Language'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Select Your Language',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Wrap(
                spacing: 16,
                runSpacing: 16,
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
                          backgroundColor: isSelected ? Theme.of(context).primaryColor : Colors.grey[200],
                          child: Icon(
                            opt.icon,
                            size: 36,
                            color: isSelected ? Colors.white : Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          opt.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  onPressed: (selectedLanguage != null && selectedLanguage.isNotEmpty)
                      ? () {
                    Navigator.pushReplacementNamed(context, SignupPage.routeName);
                  }
                      : null,
                  child: const Text('Get Started'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
