// lib/screens/home/lawyer_dashboard.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../stores/case_store.dart';
import '../../models/case_model.dart';
import '../../shared/constants/colors.dart';
import 'case_detail_page.dart';

class LawyerDashboard extends ConsumerWidget {
  static const routeName = '/lawyer_dashboard';
  const LawyerDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(caseStoreProvider);
    final items = store.items;

    final total = items.length;
    // robust status checks (cases may not have 'status' field)
    final open = items.where((c) => (c.status ?? '').toLowerCase() != 'closed' && (c.status ?? '').toLowerCase() != 'resolved').length;
    final closed = items.where((c) => (c.status ?? '').toLowerCase() == 'closed' || (c.status ?? '').toLowerCase() == 'resolved').length;
    final upcoming = items.where((c) => c.nextCourtDate != null && c.nextCourtDate!.isAfter(DateTime.now())).toList()
      ..sort((a, b) => a.nextCourtDate!.compareTo(b.nextCourtDate!));

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard'), backgroundColor: AppColors.primary),
      body: RefreshIndicator(
        onRefresh: () => ref.read(caseStoreProvider.notifier).loadCases(force: true),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // stats row
            Row(
              children: [
                _StatCard(label: 'Total', value: total.toString(), color: AppColors.primary),
                const SizedBox(width: 12),
                _StatCard(label: 'Open', value: open.toString(), color: Colors.orange),
                const SizedBox(width: 12),
                _StatCard(label: 'Closed', value: closed.toString(), color: Colors.green),
              ],
            ),
            const SizedBox(height: 18),

            // Upcoming hearings
            Text('Upcoming court dates', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            if (upcoming.isEmpty)
              const Text('No upcoming hearings')
            else
              Column(
                children: upcoming.take(5).map((c) {
                  final date = c.nextCourtDate != null ? '${c.nextCourtDate!.toLocal().toString().split(' ').first}' : 'TBC';
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(c.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(date),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CaseDetailPage(caseId: c.id))),
                  );
                }).toList(),
              ),

            const SizedBox(height: 20),
            // Recent cases
            Text('Recent cases', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            if (items.isEmpty)
              const Text('No cases yet')
            else
              Column(
                children: items.take(8).map((c) {
                  return Card(
                    child: ListTile(
                      title: Text(c.title),
                      subtitle: Text(c.description ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CaseDetailPage(caseId: c.id))),
                    ),
                  );
                }).toList(),
              ),

            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/create-case'),
              icon: const Icon(Icons.add),
              label: const Text('Create new case'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.12)),
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}
