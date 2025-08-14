// lib/screens/home/case_create_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../shared/constants/colors.dart';
import '../../stores/case_store.dart'; // <- make sure this path matches your project
import '../../models/case_model.dart';

class AddCasePage extends ConsumerStatefulWidget {
  static const routeName = '/add-case';
  const AddCasePage({super.key});

  @override
  ConsumerState<AddCasePage> createState() => _AddCasePageState();
}

class _AddCasePageState extends ConsumerState<AddCasePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _caseType = 'Civil';
  DateTime? _nextCourtDate;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _nextCourtDate ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() => _nextCourtDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Build payload that matches the repository/server expectations
    final payload = <String, dynamic>{
      'title': _titleController.text.trim(),
      if (_descriptionController.text.trim().isNotEmpty) 'description': _descriptionController.text.trim(),
      'case_type': _caseType.toLowerCase(), // server may expect lowercase
      'status': 'open',
      if (_nextCourtDate != null) 'court_date': _nextCourtDate!.toUtc().toIso8601String(),
    };

    try {
      // call createCase on the CaseStore (StateNotifier). Adjust method if your store API differs.
      final created = await ref.read(caseStoreProvider.notifier).createCase(payload);

      // Refresh the case list in the store so UIs update
      await ref.read(caseStoreProvider.notifier).loadCases();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Case created successfully'), backgroundColor: Colors.green),
      );
      Navigator.of(context).pop(created); // return created CaseModel if caller wants it
    } catch (e) {
      // The store should set state.error for server errors; show friendly message
      final storeState = ref.read(caseStoreProvider);
      final message = storeState.error ?? e.toString();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating case: $message'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final storeState = ref.watch(caseStoreProvider);
    final isLoading = storeState.isLoading;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Add New Case', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Case Title',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _caseType,
                items: const [
                  DropdownMenuItem(value: 'Civil', child: Text('Civil')),
                  DropdownMenuItem(value: 'Criminal', child: Text('Criminal')),
                  DropdownMenuItem(value: 'Family', child: Text('Family')),
                  DropdownMenuItem(value: 'Other', child: Text('Other')),
                ],
                onChanged: (val) {
                  if (val == null) return;
                  setState(() => _caseType = val);
                },
                decoration: const InputDecoration(
                  labelText: 'Case Type',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Next Court Date'),
                subtitle: Text(_nextCourtDate != null ? DateFormat.yMMMd().format(_nextCourtDate!) : 'Not set'),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: _pickDate,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  child: isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)))
                      : const Text('Create Case'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
