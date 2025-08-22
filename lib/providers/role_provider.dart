// lib/providers/role_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

enum AppRole { client, lawyer, admin }

final secureStorageProvider = Provider((ref) => const FlutterSecureStorage());

// persisted role key
const _kRoleKey = 'app_role';

final roleProvider = StateProvider<AppRole?>((ref) => null);

/// Helper to load role from secure storage (call on app start)
Future<void> restoreRole(WidgetRef ref) async {
  final storage = ref.read(secureStorageProvider);
  final raw = await storage.read(key: _kRoleKey);
  if (raw != null) {
    final role = AppRole.values.firstWhere((r) => r.toString() == raw, orElse: () => AppRole.client);
    ref.read(roleProvider.notifier).state = role;
  }
}

Future<void> persistRole(WidgetRef ref, AppRole role) async {
  final storage = ref.read(secureStorageProvider);
  await storage.write(key: _kRoleKey, value: role.toString());
  ref.read(roleProvider.notifier).state = role;
}
