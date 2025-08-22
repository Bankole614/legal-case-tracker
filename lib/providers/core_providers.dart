// lib/providers/core_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// HiSend config holder
class HiSendConfig {
  final String projectId;
  final String apiKey;
  final String baseUrl;

  HiSendConfig({
    required this.projectId,
    required this.apiKey,
    required this.baseUrl,
  });
}

/// Provide your HiSend credentials here
final hisendConfigProvider = Provider<HiSendConfig>((ref) {
  return HiSendConfig(
    projectId: '01k2582fn9q5by5aej0xdqyvy1',
    apiKey: 'dev_5YOE9TIWD4D7GLvGojwFatGE',
    baseUrl: 'https://core.hisend.hunnovate.com/api/v1/',
  );
});

/// Secure storage provider
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

/// Dio provider
final dioProvider = Provider<Dio>((ref) {
  final cfg = ref.read(hisendConfigProvider);
  final secureStorage = ref.read(secureStorageProvider);

  final options = BaseOptions(
    baseUrl: cfg.baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 20),
    responseType: ResponseType.json,
  );

  final dio = Dio(options);

  // Interceptor for API key and token
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      try {
        // Add api_key query param
        final qp = Map<String, dynamic>.from(options.queryParameters ?? {});
        if (!qp.containsKey('api_key')) {
          qp['api_key'] = cfg.apiKey;
          options.queryParameters = qp;
        }

        // Attach bearer token if present
        final token = await secureStorage.read(key: 'hisend_token');
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
      } catch (_) {
        // continue on error
      }
      return handler.next(options);
    },
    onError: (err, handler) {
      return handler.next(err);
    },
  ));

  // Add logging
  dio.interceptors.add(
    LogInterceptor(
      requestHeader: false,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
      logPrint: (obj) {
        print('[DIO] $obj');
      },
    ),
  );

  return dio;
});