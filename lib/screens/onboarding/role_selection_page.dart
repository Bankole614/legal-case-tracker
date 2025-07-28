// [1] role_selection_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_providers.dart';
import 'language_selection_page.dart'; // Make sure this import is correct

// Define the _Option class (if not already defined or imported from a shared file)
class _Option {
  final String name;
  final String code;
  final IconData icon;
  const _Option(this.name, this.code, this.icon);
}


class RoleSelectionPage extends ConsumerWidget {
  static const String routeName = '/role-selection';

  // Make _Option const if its constructor is const
  final List<_Option> roles = const [ // Assuming _Option has a const constructor
    _Option('Client', 'client', Icons.person_outline),
    _Option('Lawyer', 'lawyer', Icons.person_pin),
  ];

  const RoleSelectionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedRole = ref.watch(roleProvider);
    final roleNotifier = ref.read(roleProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Your Role'),
        automaticallyImplyLeading: false, // Good if this is a main step
        centerTitle: true, // Centers the AppBar title
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch, // <--- Makes children like Text and Button take full width
            children: [
              const Text(
                'I am a',
                textAlign: TextAlign.center, // <--- Horizontally centers the text within its bounds
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              Wrap(
                spacing: 40,
                runSpacing: 24,
                alignment: WrapAlignment.center, // <--- Centers the items within the Wrap widget itself
                children: roles.map((opt) {
                  final isSelected = selectedRole == opt.code;
                  return GestureDetector(
                    onTap: () => roleNotifier.setRole(opt.code),
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
                            fontSize: 18,
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
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: (selectedRole != null && selectedRole.isNotEmpty)
                    ? () {
                  Navigator.pushNamed(context, LanguageSelectionPage.routeName);
                }
                    : null,
                child: const Text('Continue to Language Selection'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
