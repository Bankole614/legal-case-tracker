// lib/widgets/role_guard.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/role_provider.dart';

class RoleGuard extends ConsumerWidget {
  final AppRole required;
  final Widget child;
  final Widget? onForbidden;

  const RoleGuard({super.key, required this.required, required this.child, this.onForbidden});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(roleProvider);
    if (role == required) return child;
    return onForbidden ??
        Scaffold(
          body: Center(child: Text('You do not have permission to view this.')),
        );
  }
}
