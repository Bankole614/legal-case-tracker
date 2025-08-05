import 'package:dio/dio.dart';
import '../models/case_model.dart';

class CaseRepository {
  final Dio dio;
  final String projectId;
  final String apiKey;

  CaseRepository({
    required this.dio,
    required this.projectId,
    required this.apiKey,
  });

  String get baseUrl => 'https://core.hisend.hunnovate.com/api/v1/projects/$projectId';

  Future<List<LegalCase>> getCases(String userId) async {
    final url = '$baseUrl/tables/cases/records?api_key=$apiKey';
    final response = await dio.get(url);
    final data = response.data as List;
    return data.map((json) => LegalCase.fromJson(json)).toList();
  }

  Future<LegalCase> getCaseById(String caseId) async {
    final url = '$baseUrl/tables/cases/records/$caseId?api_key=$apiKey';
    final response = await dio.get(url);
    return LegalCase.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> createCase(LegalCase c, String userId) async {
    final url = '$baseUrl/tables/cases/records?api_key=$apiKey';
    final payload = c.toJson();
    payload['userId'] = userId;
    await dio.post(url, data: payload);
  }

  Future<void> updateCase(LegalCase c) async {
    final url = '$baseUrl/tables/cases/records/${c.id}?api_key=$apiKey';
    await dio.put(url, data: c.toJson());
  }

  Future<void> deleteCase(String caseId) async {
    final url = '$baseUrl/tables/cases/records/$caseId?api_key=$apiKey';
    await dio.delete(url);
  }
}