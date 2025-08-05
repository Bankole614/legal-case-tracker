import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../models/case_model.dart';
import '../repository/case_repository.dart';

final dioProvider = Provider<Dio>((ref) => Dio());

final hiSendConfigProvider = Provider<HiSendConfig>((ref) {
  // TODO: Replace with your actual projectId and apiKey
  return HiSendConfig(
    projectId: 'YOUR_PROJECT_ID',
    apiKey: 'YOUR_API_KEY',
  );
});

class HiSendConfig {
  final String projectId;
  final String apiKey;
  HiSendConfig({required this.projectId, required this.apiKey});
}

final caseRepoProvider = Provider<CaseRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final config = ref.watch(hiSendConfigProvider);
  return CaseRepository(
    dio: dio,
    projectId: config.projectId,
    apiKey: config.apiKey,
  );
});

final casesProvider = FutureProvider<List<LegalCase>>((ref) async {
  final repo = ref.watch(caseRepoProvider);
  // Optionally filter by userId if you store it in HiSend
  return repo.getCases('');
});

final caseDetailProvider = FutureProvider.family<LegalCase, String>((ref, id) async {
  final repo = ref.watch(caseRepoProvider);
  return repo.getCaseById(id);
});