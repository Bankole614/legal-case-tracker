// lib/screens/profile/profile_page.dart
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/constants/colors.dart';
import '../../shared/widgets/gradient_button.dart';
import '../../stores/auth_store.dart';
import '../../providers/core_providers.dart';
import 'settings_page.dart';

class ProfilePage extends ConsumerStatefulWidget {
  static const routeName = '/profile';
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  bool _busy = false;

  Future<void> _refreshUser() async {
    try {
      await ref.read(authStoreProvider.notifier).getCurrentUser();
    } catch (_) {
      // ignore; auth store will set error state
    }
  }

  Future<void> _logout() async {
    setState(() => _busy = true);
    try {
      await ref.read(authStoreProvider.notifier).logout();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _openEditDialog() async {
    final authState = ref.read(authStoreProvider);
    final user = authState.user;
    final nameParts = (user?.name ?? '').split(' ');
    final first = TextEditingController(text: nameParts.isNotEmpty ? nameParts.first : '');
    final last = TextEditingController(text: nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '');
    final email = TextEditingController(text: user?.email ?? '');
    final phone = TextEditingController(text: user?.phone ?? '');

    final formKey = GlobalKey<FormState>();
    final result = await showDialog<bool>(
      context: context,
      builder: (dctx) => AlertDialog(
        title: const Text('Edit profile'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(controller: first, decoration: const InputDecoration(labelText: 'First name'), validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null),
                const SizedBox(height: 8),
                TextFormField(controller: last, decoration: const InputDecoration(labelText: 'Last name')),
                const SizedBox(height: 8),
                TextFormField(controller: email, decoration: const InputDecoration(labelText: 'Email'), keyboardType: TextInputType.emailAddress, validator: (v) => v != null && v.contains('@') ? null : 'Invalid email'),
                const SizedBox(height: 8),
                TextFormField(controller: phone, decoration: const InputDecoration(labelText: 'Phone'), keyboardType: TextInputType.phone),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dctx).pop(false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              Navigator.of(dctx).pop(true);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != true) return;

    // Build payload
    final payload = <String, dynamic>{
      if (first.text.trim().isNotEmpty || last.text.trim().isNotEmpty) 'name': ('${first.text.trim()} ${last.text.trim()}').trim(),
      if (email.text.trim().isNotEmpty) 'email': email.text.trim(),
      if (phone.text.trim().isNotEmpty) 'phone': phone.text.trim(),
    };

    if (payload.isEmpty) return;

    // call HiSend update user endpoint via Dio (we call it directly here)
    setState(() => _busy = true);
    try {
      final dio = ref.read(dioProvider);
      final cfg = ref.read(hisendConfigProvider);
      final token = ref.read(authStoreProvider).token;

      final url = 'projects/${cfg.projectId}/auth/user?api_key=${cfg.apiKey}';
      final opts = Options(headers: {
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      });

      final resp = await dio.put(url, data: payload, options: opts);

      // on success, refresh user in AuthStore
      await ref.read(authStoreProvider.notifier).getCurrentUser();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated'), backgroundColor: Colors.green));
    } on DioException catch (e) {
      final msg = e.response?.data is Map ? (e.response!.data['message'] ?? e.response!.data['error'] ?? e.message) : e.message;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Update failed: $msg'), backgroundColor: Colors.red));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Update failed: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _changePassword() async {
    final userEmail = ref.read(authStoreProvider).user?.email;
    if (userEmail == null || userEmail.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No email available for password reset'), backgroundColor: Colors.orange));
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(authStoreProvider.notifier).requestPasswordReset(email: userEmail);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password reset email sent'), backgroundColor: Colors.green));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not send reset: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStoreProvider);
    final user = authState.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage())),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshUser,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 8),
              CircleAvatar(
                radius: 56,
                backgroundColor: AppColors.primary.withOpacity(0.12),
                child: Text(
                  (user?.name != null && user!.name!.isNotEmpty) ? user.name!.substring(0, 1).toUpperCase() : 'U',
                  style: const TextStyle(fontSize: 36, color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 12),
              Text(user?.name ?? 'Unnamed user', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 6),
              Text(user?.email ?? 'No email', style: const TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 18),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      _infoRow('Email', user?.email ?? '-'),
                      const Divider(),
                      _infoRow('Phone', user?.phone ?? '-'),
                      const Divider(),
                      _infoRow('Verified', (user?.emailVerified == true ? 'Email' : '') + (user?.phoneVerified == true ? (user?.emailVerified == true ? ' • Phone' : 'Phone') : '')),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),

              Row(
                children: [
                  Expanded(
                    child: GradientButton(
                      text: 'Edit Profile',
                      onPressed: _busy ? null : _openEditDialog,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 14)),
                      icon: const Icon(Icons.lock_outline),
                      label: const Text('Password'),
                      onPressed: _busy ? null : _changePassword,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, padding: const EdgeInsets.symmetric(vertical: 14)),
                icon: _busy ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.logout),
                label: const Text('Logout'),
                onPressed: _busy ? null : _logout,
              ),
              const SizedBox(height: 20),

              if (authState.error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text('Error: ${authState.error}', style: const TextStyle(color: Colors.red)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      children: [
        Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
        const SizedBox(width: 12),
        Expanded(child: Text(value, textAlign: TextAlign.right, style: const TextStyle(color: AppColors.textSecondary))),
      ],
    );
  }
}
