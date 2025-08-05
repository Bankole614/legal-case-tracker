import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/case_model.dart';
import '../providers/case_provider.dart';

class CaseDetailPage extends ConsumerWidget {
  static const routeName = '/case-detail';

  final String caseId;

  const CaseDetailPage({Key? key, required this.caseId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final caseAsync = ref.watch(caseDetailProvider(caseId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Case Details'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: navigate to edit-case form
            },
          ),
        ],
      ),
      body: caseAsync.when(
        data: (legalCase) => _buildDetail(context, legalCase),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildDetail(BuildContext context, LegalCase c) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          Text(
            c.title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            c.description.isNotEmpty ? c.description : 'No description provided',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.calendar_today),
              const SizedBox(width: 8),
              Text(
                'Next Court Date: ${c.nextCourtDate != null ? DateFormat.yMMMd().format(c.nextCourtDate!) : 'TBD'}',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          const Divider(height: 32),
          const Text('Tasks', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          // TODO: list tasks (could navigate to tasks page or inline list)
          ElevatedButton.icon(
            onPressed: () {
              // TODO: add task
            },
            icon: const Icon(Icons.add_task),
            label: const Text('Add Task'),
          ),
          const Divider(height: 32),
          const Text('Documents', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: navigate to DocumentsPage with filter for this case
            },
            icon: const Icon(Icons.upload_file),
            label: const Text('Add Document'),
          ),
        ],
      ),
    );
  }
}

