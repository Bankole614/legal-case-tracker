// add_case_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/case_model.dart';
import '../../providers/case_provider.dart';
import '../../shared/constants/colors.dart';

class AddCasePage extends ConsumerStatefulWidget {
  static const routeName = '/add-case';
  const AddCasePage({Key? key}) : super(key: key);

  @override
  ConsumerState<AddCasePage> createState() => _AddCasePageState();
}

class _AddCasePageState extends ConsumerState<AddCasePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _caseType = 'Civil';
  DateTime? _nextCourtDate;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() => _nextCourtDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final repo = ref.read(caseRepoProvider);
    final userId = ''; // TODO: fetch from auth provider

    final newCase = LegalCase(
      id: UniqueKey().toString(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      caseType: _caseType,
      createdAt: DateTime.now(),
      nextCourtDate: _nextCourtDate,
    );

    try {
      await repo.createCase(newCase, userId);
      // Invalidate and refresh
      ref.invalidate(casesProvider);
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating case: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                validator: (val) =>
                val == null || val.isEmpty ? 'Title is required' : null,
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
                onChanged: (val) => setState(() => _caseType = val!),
                decoration: const InputDecoration(
                  labelText: 'Case Type',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Next Court Date'),
                subtitle: Text(_nextCourtDate != null
                    ? DateFormat.yMMMd().format(_nextCourtDate!)
                    : 'Not set'),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: _pickDate,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Create Case'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
