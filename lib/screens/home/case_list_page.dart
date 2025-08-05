import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/case_model.dart';
import '../providers/case_provider.dart';

class CaseListPage extends ConsumerWidget {
  final void Function()? onAddCase;
  const CaseListPage({Key? key, this.onAddCase}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final casesAsync = ref.watch(casesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cases'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: onAddCase,
          ),
        ],
      ),
      body: casesAsync.when(
        data: (cases) {
          if (cases.isEmpty) {
            return const Center(child: Text('No cases found.'));
          }
          return ListView.builder(
            itemCount: cases.length,
            itemBuilder: (context, index) {
              final c = cases[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  leading: const Icon(Icons.folder),
                  title: Text(c.title),
                  subtitle: Text(
                    'Next Court: ${c.nextCourtDate != null ? DateFormat.yMMMd().format(c.nextCourtDate!) : 'TBD'}',
                  ),
                  onTap: () {
                    // TODO: Navigate to case detail page
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
