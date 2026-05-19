import 'package:dio/dio.dart';
import 'package:farmzy/core/config/app_config.dart';
import 'package:farmzy/core/network/auth_interceptor.dart';
import 'package:farmzy/core/network/lang_interceptor.dart';
import 'package:farmzy/core/network/maintenance_interceptor.dart';
import 'package:farmzy/core/network/retry_interceptor.dart';
import 'package:farmzy/core/storage/secure_storage_service.dart';
import 'package:farmzy/features/auth/providers/role_selection_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  // Exponential Backoff & Dynamic Host Failover Interceptor
  dio.interceptors.add(RetryInterceptor(dio: dio));

  // Full Logging Interceptor (Standard Dio LogInterceptor)
  dio.interceptors.add(
    LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
    ),
  );

  // Custom Debug Logging Interceptor
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        print("🌐 REQUEST → ${options.uri}");
        print("📦 DATA → ${options.data}");
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print("✅ RESPONSE → ${response.statusCode}");
        return handler.next(response);
      },
      onError: (e, handler) {
        print("❌ ERROR TYPE → ${e.type}");
        print("❌ MESSAGE → ${e.message}");
        print("❌ URL → ${e.requestOptions.uri}");
        return handler.next(e);
      },
    ),
  );

  // Auth Interceptor
  final storage = ref.read(secureStorageServiceProvider);
  dio.interceptors.add(
    AuthInterceptor(
      storage,
      onUnauthorized: () async {
        ref.read(authInvalidationProvider.notifier).state++;
      },
    ),
  );

  // Language Interceptor
  dio.interceptors.add(LangInterceptor(ref));

  // Maintenance Interceptor (must be last — runs after auth/lang interceptors)
  dio.interceptors.add(MaintenanceInterceptor(ref));

  return dio;
});
