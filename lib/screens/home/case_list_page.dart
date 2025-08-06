import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/case_model.dart';
import '../../providers/case_provider.dart';
import 'package:intl/intl.dart';

import '../../shared/constants/colors.dart';
import 'case_detail_page.dart';

class CaseListPage extends ConsumerWidget {
  const CaseListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final casesAsync = ref.watch(casesProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('My Cases', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              // TODO: settings
            },
          ),
        ],
      ),
      body: casesAsync.when(
        data: (cases) {
          if (cases.isEmpty) return const Center(child: Text('No cases found.'));
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: cases.length,
            itemBuilder: (ctx, i) {
              final c = cases[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(Icons.folder, color: AppColors.primary),
                  title: Text(c.title),
                  subtitle: Text(
                    c.nextCourtDate != null
                        ? 'Next: ${DateFormat.yMMMd().format(c.nextCourtDate!)}'
                        : 'Next: TBD',
                  ),
                  onTap: () => Navigator.pushNamed(
                    context,
                    CaseDetailPage.routeName,
                    arguments: c.id,
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => Navigator.pushNamed(context, '/add-case'),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

