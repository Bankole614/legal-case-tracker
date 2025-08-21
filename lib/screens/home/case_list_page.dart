import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/case_model.dart';
import '../../stores/case_store.dart';
import '../../shared/constants/colors.dart';
import 'case_create_page.dart';
import 'case_detail_page.dart'; // if you use direct navigation; otherwise use named route

class CaseListPage extends ConsumerStatefulWidget {
  static const routeName = '/cases';
  const CaseListPage({Key? key}) : super(key: key);

  @override
  ConsumerState<CaseListPage> createState() => _CaseListPageState();
}

class _CaseListPageState extends ConsumerState<CaseListPage> {
  @override
  void initState() {
    super.initState();
    // load cases when page appears
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(caseStoreProvider.notifier).loadCases(force: true);
    });
  }

  Future<void> _onRefresh() async {
    await ref.read(caseStoreProvider.notifier).loadCases(force: true);
  }

  void _openCreate() async {
    final created = await Navigator.push(context, MaterialPageRoute(builder: (_) => const CaseCreatePage()));
    if (created != null) {
      // reload list
      await ref.read(caseStoreProvider.notifier).loadCases(force: true);
    }
  }

  void _openDetail(CaseModel c) {
    // Use named route if you set it up in main.dart, or navigate directly:
    // Navigator.pushNamed(context, '/cases/detail', arguments: c.id);
    Navigator.push(context, MaterialPageRoute(builder: (_) => CaseDetailPage(caseId: c.id)));
  }

  @override
  Widget build(BuildContext context) {
    final store = ref.watch(caseStoreProvider);
    final items = store.items;

    return Scaffold(
      appBar: AppBar(title: const Text('Cases'), backgroundColor: AppColors.primary),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: Builder(builder: (ctx) {
          if (store.isLoading && items.isEmpty) return const Center(child: CircularProgressIndicator());
          if (store.error != null && items.isEmpty) {
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text('Error: ${store.error}', style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 8),
                ElevatedButton(onPressed: () => ref.read(caseStoreProvider.notifier).loadCases(force: true), child: const Text('Retry'))
              ]),
            );
          }
          if (items.isEmpty) {
            return const Center(child: Text('No cases yet. Tap + to create one.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(8),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (ctx, i) {
              final c = items[i];
              return Card(
                child: ListTile(
                  title: Text(c.title),
                  subtitle: Text(c.description ?? ''),
                  onTap: () => _openDetail(c),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (dctx) => AlertDialog(
                          title: const Text('Delete case'),
                          content: Text('Delete "${c.title}"?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(dctx, false), child: const Text('Cancel')),
                            TextButton(onPressed: () => Navigator.pop(dctx, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                          ],
                        ),
                      );
                      if (ok == true) {
                        try {
                          await ref.read(caseStoreProvider.notifier).deleteCase(c.id);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Deleted'), backgroundColor: Colors.green));
                        } catch (e) {
                          final err = ref.read(caseStoreProvider).error ?? e.toString();
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Delete failed: $err'), backgroundColor: Colors.red));
                        }
                      }
                    },
                  ),
                ),
              );
            },
          );
        }),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: _openCreate,
        child: const Icon(Icons.add),
      ),
    );
  }
}
