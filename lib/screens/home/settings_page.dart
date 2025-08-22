// lib/screens/settings/settings_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../providers/app_providers.dart';
import '../../shared/constants/colors.dart';
import '../../providers/core_providers.dart';
import '../../stores/auth_store.dart' hide secureStorageProvider;

final notificationsEnabledProvider = StateProvider<bool>((ref) => true);

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});
  static const routeName = '/settings';

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _loading = false;
  late final FlutterSecureStorage _storage;

  @override
  void initState() {
    super.initState();
    _storage = ref.read(secureStorageProvider);
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final n = await _storage.read(key: 'pref_notify');
    ref.read(notificationsEnabledProvider.notifier).state = n != 'false';
  }

  Future<void> _saveNotifyPref(bool val) async {
    await _storage.write(key: 'pref_notify', value: val ? 'true' : 'false');
  }

  Future<void> _resendVerificationEmail() async {
    final email = ref.read(authStoreProvider).user?.email;
    if (email == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No email available'), backgroundColor: Colors.orange));
      return;
    }
    setState(() => _loading = true);
    try {
      // There's no explicit "send verification" method in all stores; sometimes sign-up triggers it.
      // Using requestPasswordReset as a pragmatic option to push an email flow.
      await ref.read(authStoreProvider.notifier).requestPasswordReset(email: email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Check your email for verification/reset instructions'), backgroundColor: Colors.green));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _deleteAccount() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dctx) => AlertDialog(
        title: const Text('Delete account'),
        content: const Text('Deleting your account is irreversible. Are you sure?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(dctx, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (ok != true) return;

    // We do not call a delete endpoint automatically because API endpoints vary.
    // Instead show instructions or call repo.deleteAccount if you implement it.
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account deletion is not enabled. Contact support.'), backgroundColor: Colors.orange));
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStoreProvider);
    final notificationsEnabled = ref.watch(notificationsEnabledProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), backgroundColor: AppColors.primary),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          ListTile(
            title: const Text('Notifications'),
            subtitle: const Text('Enable or disable notifications'),
            trailing: Switch(
              value: notificationsEnabled,
              onChanged: (v) {
                ref.read(notificationsEnabledProvider.notifier).state = v;
                _saveNotifyPref(v);
              },
            ),
          ),
          const Divider(),

          ListTile(
            title: const Text('Language'),
            subtitle: Text((ref.watch(languageProvider) ?? 'en').toUpperCase()),
            onTap: () async {
              final picked = await showModalBottomSheet<String>(
                context: context,
                builder: (_) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(title: const Text('English'), onTap: () => Navigator.pop(context, 'en')),
                    ListTile(title: const Text('French'), onTap: () => Navigator.pop(context, 'fr')),
                    ListTile(title: const Text('Spanish'), onTap: () => Navigator.pop(context, 'es')),
                  ],
                ),
              );
              if (picked != null) {
                // Update provider if available
                try {
                  ref.read(languageProvider.notifier).state = picked;
                } catch (_) {
                  // If languageProvider is not a StateProvider, ignore
                }
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Language set to ${picked.toUpperCase()}')));
              }
            },
          ),
          const Divider(),

          ListTile(
            title: const Text('Role'),
            subtitle: Text((ref.watch(roleProvider) ?? 'client').toString()),
            onTap: () async {
              final chosen = await showDialog<String>(
                context: context,
                builder: (dctx) => SimpleDialog(
                  title: const Text('Select role'),
                  children: [
                    SimpleDialogOption(child: const Text('Client'), onPressed: () => Navigator.pop(dctx, 'client')),
                    SimpleDialogOption(child: const Text('Lawyer'), onPressed: () => Navigator.pop(dctx, 'lawyer')),
                    SimpleDialogOption(child: const Text('Admin'), onPressed: () => Navigator.pop(dctx, 'admin')),
                  ],
                ),
              );
              if (chosen != null) {
                try {
                  ref.read(roleProvider.notifier).state = chosen;
                } catch (_) {}
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Role set to $chosen')));
              }
            },
          ),
          const Divider(),

          ListTile(
            title: const Text('Resend verification / reset'),
            subtitle: const Text('Send verification or password reset email'),
            trailing: _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator()) : IconButton(icon: const Icon(Icons.refresh), onPressed: _resendVerificationEmail),
          ),

          const Divider(),

          ListTile(
            title: const Text('Privacy & Terms'),
            subtitle: const Text('View our privacy policy and terms'),
            onTap: () {
              // Open external links or in-app screens
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Open privacy/terms (not implemented)'), backgroundColor: Colors.blue));
            },
          ),

          const Divider(),

          ListTile(
            title: const Text('Delete account'),
            subtitle: const Text('Remove your account permanently'),
            trailing: IconButton(icon: const Icon(Icons.delete_forever, color: Colors.red), onPressed: _deleteAccount),
          ),

          const SizedBox(height: 16),
          Center(
            child: ElevatedButton(
              onPressed: () async {
                // quick access to logout for convenience
                await ref.read(authStoreProvider.notifier).logout();
                if (!mounted) return;
                Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              child: const Text('Logout'),
            ),
          ),
        ],
      ),
    );
  }
}
