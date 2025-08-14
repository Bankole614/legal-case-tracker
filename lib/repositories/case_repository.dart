import 'package:dio/dio.dart';
import '../providers/core_providers.dart';

class CaseRepository {
  final Dio dio;
  final HiSendConfig cfg;
  final String tableName;
  CaseRepository({required this.dio, required this.cfg, this.tableName = 'cases'});

  String _base() => 'projects/${cfg.projectId}/records/$tableName';

  Future<dynamic> listCases({Map<String, dynamic>? query}) async {
    final qp = {'api_key': cfg.apiKey, if (query != null) ...query};
    final resp = await dio.get(_base(), queryParameters: qp);
    return resp.data;
  }

  Future<Map<String, dynamic>> createCase(Map<String, dynamic> data) async {
    final resp = await dio.post(_base(), data: data, queryParameters: {'api_key': cfg.apiKey});
    final normalized = _normalize(resp.data);
    return normalized;
  }

  Future<dynamic> getCase(String id) async {
    final resp = await dio.get('${_base()}/$id', queryParameters: {'api_key': cfg.apiKey});
    return resp.data;
  }

  Future<Map<String, dynamic>> updateCase(String id, Map<String, dynamic> updates) async {
    final resp = await dio.put('${_base()}/$id', data: updates, queryParameters: {'api_key': cfg.apiKey});
    return _normalize(resp.data);
  }

  Future<void> deleteCase(String id) async {
    await dio.delete('${_base()}/$id', queryParameters: {'api_key': cfg.apiKey});
  }

  Map<String, dynamic> _normalize(dynamic data) {
    if (data is Map<String, dynamic>) {
      if (data.containsKey('data') && data['data'] is Map<String, dynamic>) return Map<String, dynamic>.from(data['data']);
      return Map<String, dynamic>.from(data);
    }
    if (data is Map) {
      final out = <String, dynamic>{};
      data.forEach((k, v) => out[k.toString()] = v);
      if (out.containsKey('data') && out['data'] is Map) {
        final inner = out['data'] as Map;
        final m = <String, dynamic>{};
        inner.forEach((k, v) => m[k.toString()] = v);
        return m;
      }
      return out;
    }
    if (data is List) return {'data': data};
    return {'result': data};
  }
}
