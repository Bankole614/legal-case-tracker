// lib/providers/case_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/case_model.dart';
import '../repositories/case_repository.dart';
import '../stores/case_store.dart';
import 'core_providers.dart';

/// Provides a CaseRepository wired with Dio + HiSend config.
final caseRepositoryProvider = Provider<CaseRepository>((ref) {
  final dio = ref.read(dioProvider);
  final cfg = ref.read(hisendConfigProvider);
  return CaseRepository(dio: dio, cfg: cfg);
});

/// StateNotifier-based store for cases (list, create, update, etc).
/// Use ref.read(caseStoreProvider.notifier) to call actions (loadCases/createCase/...).
final caseStoreProvider = StateNotifierProvider<CaseStore, CaseState>((ref) {
  final repo = ref.read(caseRepositoryProvider);
  return CaseStore(repo: repo);
});

/// Helper: safely extract a List<dynamic> from many possible response envelopes
List<dynamic> _extractListFromResponse(dynamic resp) {
  if (resp == null) return <dynamic>[];
  if (resp is List) return resp.cast<dynamic>();
  if (resp is Map<String, dynamic>) {
    // { "data": [ .. ] }
    if (resp['data'] is List) return (resp['data'] as List).cast<dynamic>();
    // { "records": [ .. ] }
    if (resp['records'] is List) return (resp['records'] as List).cast<dynamic>();
    // { "data": { "records": [ .. ] } }
    if (resp['data'] is Map && resp['data']['records'] is List) {
      return (resp['data']['records'] as List).cast<dynamic>();
    }
    // fallback: find first list value
    for (final v in resp.values) {
      if (v is List) return (v).cast<dynamic>();
    }
  } else if (resp is Map) {
    // Map with dynamic keys
    for (final v in resp.values) {
      if (v is List) return (v).cast<dynamic>();
    }
  }
  return <dynamic>[];
}

/// Cases list provider (use family to pass query/pagination params).
/// Example:
///   ref.watch(casesListProvider({'limit': 50, 'page': 1}));
final casesListProvider = FutureProvider.autoDispose
    .family<List<CaseModel>, Map<String, dynamic>?>((ref, query) async {
  final repo = ref.read(caseRepositoryProvider);
  final mergedQuery = <String, dynamic>{if (query != null) ...query};
  final resp = await repo.listCases(query: mergedQuery);

  final rawList = _extractListFromResponse(resp);

  final models = rawList.map<CaseModel>((e) {
    if (e is Map<String, dynamic>) return CaseModel.fromJson(e);
    if (e is Map) return CaseModel.fromJson(Map<String, dynamic>.from(e));
    return CaseModel(id: e.toString(), title: e.toString());
  }).toList();

  return models;
});

/// Single case detail provider
/// Usage:
///   ref.watch(caseDetailProvider(caseId));
final caseDetailProvider = FutureProvider.autoDispose.family<CaseModel, String>((ref, caseId) async {
  final repo = ref.read(caseRepositoryProvider);
  final resp = await repo.getCase(caseId);

  // resp might be:
  // - Map (direct record)
  // - Map with envelope: { data: { ... } }
  // - other shapes (we handle safely)
  if (resp is Map<String, dynamic>) {
    if (resp.containsKey('data') && resp['data'] is Map) {
      return CaseModel.fromJson(Map<String, dynamic>.from(resp['data']));
    }
    return CaseModel.fromJson(resp);
  }
  if (resp is Map) {
    return CaseModel.fromJson(Map<String, dynamic>.from(resp));
  }

  // Fallback: try to extract from envelope-like objects
  try {
    if (resp != null && resp is Map && resp['data'] is Map) {
      return CaseModel.fromJson(Map<String, dynamic>.from(resp['data']));
    }
  } catch (_) {}

  // If nothing matches return a minimal placeholder model
  return CaseModel(id: caseId, title: 'Unknown case');
});
