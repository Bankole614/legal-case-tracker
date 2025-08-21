// lib/stores/case_store.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../models/case_model.dart';
import '../repositories/case_repository.dart';
import '../providers/core_providers.dart';

final caseRepositoryProvider = Provider<CaseRepository>((ref) {
  final dio = ref.read(dioProvider);
  final cfg = ref.read(hisendConfigProvider);
  return CaseRepository(dio: dio, cfg: cfg);
});

final caseStoreProvider = StateNotifierProvider<CaseStore, CaseState>((ref) {
  final repo = ref.read(caseRepositoryProvider);
  return CaseStore(repo: repo);
});

class CaseState {
  final List<CaseModel> items;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int page;
  final int perPage;
  final String? error;
  final Map<String, List<String>> validationErrors;

  const CaseState({
    this.items = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.page = 1,
    this.perPage = 20,
    this.error,
    this.validationErrors = const {},
  });

  CaseState copyWith({
    List<CaseModel>? items,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? page,
    int? perPage,
    String? error,
    Map<String, List<String>>? validationErrors,
  }) {
    return CaseState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      perPage: perPage ?? this.perPage,
      error: error,
      validationErrors: validationErrors ?? this.validationErrors,
    );
  }
}

class CaseStore extends StateNotifier<CaseState> {
  final CaseRepository repo;

  CaseStore({required this.repo}) : super(const CaseState());

  // Defensive extractor: converts several possible response envelopes into a List
  List<dynamic> _extractList(dynamic resp) {
    if (resp == null) return <dynamic>[];
    if (resp is List) return resp;
    if (resp is Map<String, dynamic>) {
      // common envelopes
      if (resp['data'] is List) return resp['data'] as List<dynamic>;
      if (resp['records'] is List) return resp['records'] as List<dynamic>;
      if (resp['data'] is Map && resp['data']['records'] is List) return resp['data']['records'] as List<dynamic>;
      // try values
      for (final v in resp.values) {
        if (v is List) return v;
      }
    } else if (resp is Map) {
      for (final v in resp.values) {
        if (v is List) return v;
      }
    }
    return <dynamic>[];
  }

  Map<String, List<String>> _normalizeValidationErrors(dynamic data) {
    try {
      if (data is Map) {
        // HiSend commonly uses {"errors": {...}} or {"data": {"errors": {...}}}
        Map? map = data['errors'] is Map ? data['errors'] : (data['data'] is Map && data['data']['errors'] is Map ? data['data']['errors'] : null);
        if (map != null) {
          final out = <String, List<String>>{};
          map.forEach((k, v) {
            if (v == null) return;
            if (v is String) out[k.toString()] = [v];
            else if (v is List) out[k.toString()] = v.map((e) => e.toString()).toList();
            else if (v is Map) out[k.toString()] = v.values.map((e) => e.toString()).toList();
            else out[k.toString()] = [v.toString()];
          });
          return out;
        }
      }
    } catch (_) {}
    return <String, List<String>>{};
  }

  /// Load first page (or specific page) of cases. Use `force=true` to ignore current cache.
  Future<void> loadCases({
    Map<String, dynamic>? query,
    bool force = false,
    int? perPage,
    int page = 1,
  }) async {
    // If not forced and already loading, skip
    if (state.isLoading && !force) return;

    state = state.copyWith(isLoading: true, error: null, validationErrors: {}, page: page, perPage: perPage ?? state.perPage);

    try {
      // Merge page/perPage into query params expected by the repository
      final qp = <String, dynamic>{
        'page': page,
        'limit': perPage ?? state.perPage,
        if (query != null) ...query,
      };

      final resp = await repo.listCases(query: qp);
      final list = _extractList(resp);
      final models = list.map<CaseModel>((e) {
        if (e is Map<String, dynamic>) return CaseModel.fromJson(e);
        if (e is Map) return CaseModel.fromJson(Map<String, dynamic>.from(e));
        return CaseModel(id: e.toString(), title: e.toString());
      }).toList();

      // If fewer items than perPage -> no more pages
      final fetchedCount = models.length;
      final hasMore = fetchedCount >= (perPage ?? state.perPage);

      state = state.copyWith(
        items: models,
        isLoading: false,
        hasMore: hasMore,
        page: page,
        perPage: perPage ?? state.perPage,
        error: null,
      );
    } on DioException catch (e) {
      final valErrs = _normalizeValidationErrors(e.response?.data);
      state = state.copyWith(isLoading: false, error: e.message, validationErrors: valErrs);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Load next page and append to existing items
  Future<void> loadMore({Map<String, dynamic>? query, int? perPage}) async {
    if (state.isLoadingMore || !state.hasMore) return;

    final nextPage = state.page + 1;
    state = state.copyWith(isLoadingMore: true, error: null);

    try {
      final qp = <String, dynamic>{
        'page': nextPage,
        'limit': perPage ?? state.perPage,
        if (query != null) ...query,
      };

      final resp = await repo.listCases(query: qp);
      final list = _extractList(resp);
      final models = list.map<CaseModel>((e) {
        if (e is Map<String, dynamic>) return CaseModel.fromJson(e);
        if (e is Map) return CaseModel.fromJson(Map<String, dynamic>.from(e));
        return CaseModel(id: e.toString(), title: e.toString());
      }).toList();

      final newItems = [...state.items, ...models];
      final fetchedCount = models.length;
      final hasMore = fetchedCount >= (perPage ?? state.perPage);

      state = state.copyWith(
        items: newItems,
        isLoadingMore: false,
        hasMore: hasMore,
        page: nextPage,
        error: null,
      );
    } on DioException catch (e) {
      final valErrs = _normalizeValidationErrors(e.response?.data);
      state = state.copyWith(isLoadingMore: false, error: e.message, validationErrors: valErrs);
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e.toString());
    }
  }

  /// Create a case and prepend it to the list
  Future<CaseModel> createCase(Map<String, dynamic> payload) async {
    state = state.copyWith(isLoading: true, error: null, validationErrors: {});
    try {
      final resp = await repo.createCase(payload);
      // repo.createCase returns normalized record map
      final model = CaseModel.fromJson(resp);
      final items = [model, ...state.items];
      state = state.copyWith(items: items, isLoading: false);
      return model;
    } on DioException catch (e) {
      final valErrs = _normalizeValidationErrors(e.response?.data);
      state = state.copyWith(isLoading: false, error: e.message, validationErrors: valErrs);
      rethrow;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  /// Update an existing case (PATCH/PUT) and update local list if present
  Future<CaseModel> updateCase(String id, Map<String, dynamic> updates) async {
    state = state.copyWith(isLoading: true, error: null, validationErrors: {});
    try {
      final resp = await repo.updateCase(id, updates);
      final updated = CaseModel.fromJson(resp);
      final idx = state.items.indexWhere((c) => c.id == id);
      final items = List<CaseModel>.from(state.items);
      if (idx >= 0) items[idx] = updated;
      state = state.copyWith(items: items, isLoading: false);
      return updated;
    } on DioException catch (e) {
      final valErrs = _normalizeValidationErrors(e.response?.data);
      state = state.copyWith(isLoading: false, error: e.message, validationErrors: valErrs);
      rethrow;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  /// Delete case and remove from local list
  Future<void> deleteCase(String id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await repo.deleteCase(id);
      final items = state.items.where((c) => c.id != id).toList();
      state = state.copyWith(items: items, isLoading: false);
    } on DioException catch (e) {
      final valErrs = _normalizeValidationErrors(e.response?.data);
      state = state.copyWith(isLoading: false, error: e.message, validationErrors: valErrs);
      rethrow;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  /// Utility: clear errors
  void clearErrors() {
    state = state.copyWith(error: null, validationErrors: {});
  }

  /// Utility: clear single field validation error
  void clearFieldError(String field) {
    final copy = Map<String, List<String>>.from(state.validationErrors);
    if (copy.containsKey(field)) {
      copy.remove(field);
      state = state.copyWith(validationErrors: copy);
    }
  }
}
