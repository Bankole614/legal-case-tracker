import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../models/case_model.dart';
import '../providers/core_providers.dart';
import '../repositories/case_repository.dart';

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
  final String? error;
  const CaseState({this.items = const [], this.isLoading = false, this.error});
  CaseState copyWith({List<CaseModel>? items, bool? isLoading, String? error}) {
    return CaseState(items: items ?? this.items, isLoading: isLoading ?? this.isLoading, error: error);
  }
}

class CaseStore extends StateNotifier<CaseState> {
  final CaseRepository repo;
  CaseStore({required this.repo}) : super(const CaseState());

  List<dynamic> _extractList(dynamic resp) {
    if (resp == null) return <dynamic>[];
    if (resp is List) return resp;
    if (resp is Map<String, dynamic>) {
      if (resp['data'] is List) return resp['data'];
      if (resp['records'] is List) return resp['records'];
      if (resp['data'] is Map && resp['data']['records'] is List) return resp['data']['records'];
      for (final v in resp.values) {
        if (v is List) return v;
      }
    }
    return <dynamic>[];
  }

  Future<void> loadCases() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final resp = await repo.listCases(query: {'limit': 50, 'page': 1});
      final list = _extractList(resp);
      final models = list.map<CaseModel>((e) {
        if (e is Map<String, dynamic>) return CaseModel.fromJson(e);
        if (e is Map) return CaseModel.fromJson(Map<String, dynamic>.from(e));
        return CaseModel(id: e.toString(), title: e.toString());
      }).toList();
      state = state.copyWith(items: models, isLoading: false);
    } on DioException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<CaseModel> createCase(Map<String, dynamic> payload) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final resp = await repo.createCase(payload);
      final model = CaseModel.fromJson(resp);
      state = state.copyWith(items: [model, ...state.items], isLoading: false);
      return model;
    } on DioException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      rethrow;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }
}
