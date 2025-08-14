import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/case_model.dart';
import '../../stores/case_store.dart';

class CaseDetailPage extends ConsumerStatefulWidget {
  final String caseId;
  const CaseDetailPage({required this.caseId, super.key});
  @override
  ConsumerState<CaseDetailPage> createState() => _CaseDetailPageState();
}

class _CaseDetailPageState extends ConsumerState<CaseDetailPage> {
  @override
  void initState() {
    super.initState();
    // Could implement a method to load single case (not implemented above),
    // Here we refresh list and pick the case from the list
    ref.read(caseStoreProvider.notifier).loadCases();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(caseStoreProvider);
    final c = state.items.firstWhere((e) => e.id == widget.caseId, orElse: () => CaseModel(id: widget.caseId, title: 'Unknown'));
    return Scaffold(appBar: AppBar(title: Text('Case ${c.title}')), body: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Title: ${c.title}', style: const TextStyle(fontSize: 18)), const SizedBox(height: 8), Text('Status: ${c.status}'), const SizedBox(height: 8), Text('Description: ${c.description ?? "-"}') ])));
  }
}
