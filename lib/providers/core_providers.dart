// lib/providers/core_providers.dart
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure storage provider
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

/// HiSend config provider (reads from dotenv if available)
final hisendConfigProvider = Provider<HiSendConfig>((ref) {
  final projectId = dotenv.env['HISEND_PROJECT_ID'] ?? 'YOUR_PROJECT_ID';
  final apiKey = dotenv.env['HISEND_API_KEY'] ?? 'YOUR_API_KEY';
  return HiSendConfig(projectId: projectId, apiKey: apiKey);
});

class HiSendConfig {
  final String projectId;
  final String apiKey;
  HiSendConfig({required this.projectId, required this.apiKey});
}

/// Dio provider with interceptor that attaches api_key and Bearer token
final dioProvider = Provider<Dio>((ref) {
  final cfg = ref.read(hisendConfigProvider);
  final storage = ref.read(secureStorageProvider);

  final dio = Dio(BaseOptions(
    baseUrl: 'https://core.hisend.hunnovate.com/api/v1/',
    connectTimeout: const Duration(seconds: 20),
    receiveTimeout: const Duration(seconds: 30),
    responseType: ResponseType.json,
  ));

  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      // Ensure api_key is present in query params (avoid overriding if already set)
      if (!options.queryParameters.containsKey('api_key')) {
        options.queryParameters = {
          ...options.queryParameters,
          'api_key': cfg.apiKey,
        };
      }

      // Attach Authorization if token exists in secure storage
      try {
        final token = await storage.read(key: 'hisend_token');
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
      } catch (_) {
        // reading storage failed — proceed without token
      }

      handler.next(options);
    },
    onError: (err, handler) {
      // Optionally inspect `err.response?.statusCode` to do retry/refresh
      handler.next(err);
    },
  ));

  return dio;
});
