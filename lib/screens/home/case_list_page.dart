// lib/screens/home/case_list_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/case_model.dart';
import '../../providers/app_providers.dart';
import '../../providers/role_provider.dart' hide roleProvider;
import '../../stores/case_store.dart';
import '../../shared/constants/colors.dart';
import 'case_create_page.dart';
import 'case_detail_page.dart';

class CaseListPage extends ConsumerStatefulWidget {
  static const routeName = '/cases';

  const CaseListPage({super.key});

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

  Future<void> _openCreate() async {
    final created = await Navigator.push<CaseModel?>(
      context,
      MaterialPageRoute(builder: (_) => const CaseCreatePage()),
    );
    if (created != null) {
      // reload list
      await ref.read(caseStoreProvider.notifier).loadCases(force: true);
    }
  }

  void _openDetail(CaseModel c) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CaseDetailPage(caseId: c.id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = ref.watch(caseStoreProvider);
    final isLoading = store.isLoading;
    final items = store.items;
    final role = ref.watch(roleProvider) ?? AppRole.client;
    final isLawyer = role == AppRole.lawyer;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cases'),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              // simple search dialog that filters locally
              final q = await showSearch<String>(
                context: context,
                delegate: _CaseSearchDelegate(items),
              );
              if (q != null && q.isNotEmpty) {
                // optional: navigate to first match
                final found = items.firstWhere(
                      (c) => c.title.toLowerCase().contains(q.toLowerCase()) || (c.description ?? '').toLowerCase().contains(q.toLowerCase()),
                  orElse: () => items.isNotEmpty ? items.first : null as CaseModel,
                );
                if (found != null) _openDetail(found);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(caseStoreProvider.notifier).loadCases(force: true),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: Builder(builder: (ctx) {
          // Loading state (first load)
          if (isLoading && items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // Error state with retry
          if (store.error != null && items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text('Error: ${store.error}', style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => ref.read(caseStoreProvider.notifier).loadCases(force: true),
                    child: const Text('Retry'),
                  ),
                ]),
              ),
            );
          }

          // Empty state
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.folder_open, size: 60, color: Colors.grey),
                  const SizedBox(height: 12),
                  const Text('No cases yet', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Create Case'),
                    onPressed: _openCreate,
                  )
                ],
              ),
            );
          }

          // Normal list
          return ListView.separated(
            padding: const EdgeInsets.all(8),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (ctx, i) {
              final c = items[i];
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
                child: ListTile(
                  isThreeLine: (c.description ?? '').isNotEmpty,
                  title: Text(c.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: c.description != null && c.description!.isNotEmpty
                      ? Text(c.description!, maxLines: 2, overflow: TextOverflow.ellipsis)
                      : null,
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withOpacity(0.12),
                    child: Text(c.title.isNotEmpty ? c.title[0].toUpperCase() : '?', style: const TextStyle(color: AppColors.primary)),
                  ),
                  onTap: () => _openDetail(c),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Edit button for lawyers
                      if (isLawyer)
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            // Implement edit flow (open detail in edit mode or a separate edit page)
                            _openDetail(c);
                          },
                        ),

                      // Delete button visible only to lawyers
                      if (isLawyer)
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            final ok = await showDialog<bool>(
                              context: context,
                              builder: (dctx) => AlertDialog(
                                title: const Text('Delete case'),
                                content: Text('Delete "${c.title}"? This action cannot be undone.'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(dctx, false), child: const Text('Cancel')),
                                  TextButton(onPressed: () => Navigator.pop(dctx, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                                ],
                              ),
                            );
                            if (ok == true) {
                              try {
                                await ref.read(caseStoreProvider.notifier).deleteCase(c.id);
                                // reload list
                                await ref.read(caseStoreProvider.notifier).loadCases(force: true);
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Deleted'), backgroundColor: Colors.green));
                              } catch (e) {
                                final err = ref.read(caseStoreProvider).error ?? e.toString();
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Delete failed: $err'), backgroundColor: Colors.red));
                              }
                            }
                          },
                        ),
                    ],
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

/// A very small local search delegate that searches in the provided cases.
class _CaseSearchDelegate extends SearchDelegate<String> {
  final List<CaseModel> items;

  _CaseSearchDelegate(this.items);

  @override
  String get searchFieldLabel => 'Search cases';

  @override
  List<Widget>? buildActions(BuildContext context) => [
    if (query.isNotEmpty) IconButton(onPressed: () => query = '', icon: const Icon(Icons.clear)),
  ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(onPressed: () => close(context, ''), icon: const Icon(Icons.arrow_back));

  @override
  Widget buildResults(BuildContext context) {
    final results = items.where((c) => c.title.toLowerCase().contains(query.toLowerCase()) || (c.description ?? '').toLowerCase().contains(query.toLowerCase())).toList();
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (_, i) => ListTile(
        title: Text(results[i].title),
        subtitle: Text(results[i].description ?? ''),
        onTap: () => close(context, query),
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = query.isEmpty
        ? items.take(6).toList()
        : items.where((c) => c.title.toLowerCase().contains(query.toLowerCase()) || (c.description ?? '').toLowerCase().contains(query.toLowerCase())).toList();
    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (_, i) => ListTile(
        title: Text(suggestions[i].title),
        subtitle: suggestions[i].description != null ? Text(suggestions[i].description!, maxLines: 1, overflow: TextOverflow.ellipsis) : null,
        onTap: () => query = suggestions[i].title,
      ),
    );
  }
}
