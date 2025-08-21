import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/widgets/auth_widgets.dart';
import '../../shared/widgets/gradient_button.dart';
import '../../stores/case_store.dart';
import '../../models/case_model.dart';

class CaseCreatePage extends ConsumerStatefulWidget {
  const CaseCreatePage({super.key});

  @override
  ConsumerState<CaseCreatePage> createState() => _CaseCreatePageState();
}

class _CaseCreatePageState extends ConsumerState<CaseCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _desc = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final payload = <String, dynamic>{
      'title': _title.text.trim(),
      if (_desc.text.trim().isNotEmpty) 'description': _desc.text.trim(),
      'status': 'open',
    };

    try {
      final created = await ref.read(caseStoreProvider.notifier).createCase(payload);
      // refresh list (if store-backed lists are used elsewhere)
      await ref.read(caseStoreProvider.notifier).loadCases(force: true);
      if (!mounted) return;
      Navigator.pop(context, created);
    } catch (e) {
      final state = ref.read(caseStoreProvider);
      final message = state.error ?? e.toString();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Create failed: $message'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Case')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              AuthTextField(
                controller: _title,
                label: 'Title',
                icon: Icons.title,
                validator: (v) => v != null && v.trim().isNotEmpty ? null : 'Title is required',
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _desc,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              GradientButton(
                text: 'Create',
                onPressed: _loading ? null : _submit,
                isLoading: _loading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
