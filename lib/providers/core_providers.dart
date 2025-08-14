import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// HiSend config model
class HiSendConfig {
  final String projectId;
  final String apiKey;
  final String baseUrl;
  HiSendConfig({
    required this.projectId,
    required this.apiKey,
    this.baseUrl = 'https://core.hisend.hunnovate.com/api/v1/',
  });
}

final hisendConfigProvider = Provider<HiSendConfig>((ref) {
  final projectId = dotenv.env['HISEND_PROJECT_ID'] ?? '';
  final apiKey = dotenv.env['HISEND_API_KEY'] ?? '';
  return HiSendConfig(projectId: projectId, apiKey: apiKey);
});

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final dioProvider = Provider<Dio>((ref) {
  final cfg = ref.read(hisendConfigProvider);
  final storage = ref.read(secureStorageProvider);

  final dio = Dio(BaseOptions(baseUrl: cfg.baseUrl, connectTimeout: const Duration(seconds: 15)));
  // Interceptor: add api_key query and bearer if token exists
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      // Add api_key as query parameter if not already present
      options.queryParameters ??= {};
      if (!options.queryParameters!.containsKey('api_key')) {
        options.queryParameters!['api_key'] = cfg.apiKey;
      }

      // Attach bearer token if saved
      final token = await storage.read(key: 'hisend_token');
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      handler.next(options);
    },
    onError: (e, handler) => handler.next(e),
  ));
  return dio;
});
