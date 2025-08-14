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
  final _title = TextEditingController();
  final _desc = TextEditingController();
  bool _loading = false;
  @override
  void dispose() { _title.dispose(); _desc.dispose(); super.dispose(); }

  Future<void> _submit() async {
    if (_title.text.trim().isEmpty) return;
    setState(() => _loading = true);
    try {
      final created = await ref.read(caseStoreProvider.notifier).createCase({'title': _title.text.trim(), 'description': _desc.text.trim()});
      if (!mounted) return;
      Navigator.pop(context, created);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    } finally { setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Create Case')), body: Padding(padding: const EdgeInsets.all(12), child: Column(children: [
      AuthTextField(controller: _title, label: 'Title', icon: Icons.title, validator: (v) => v!=null && v.isNotEmpty ? null : 'Required'),
      const SizedBox(height: 8),
      TextFormField(controller: _desc, maxLines: 4, decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder())),
      const SizedBox(height: 12),
      GradientButton(text: 'Create', onPressed: _loading ? null : _submit, isLoading: _loading)
    ])));
  }
}
