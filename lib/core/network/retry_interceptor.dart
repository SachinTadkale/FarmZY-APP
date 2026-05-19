import 'dart:io';
import 'package:dio/dio.dart';
import 'package:farmzy/core/config/app_config.dart';

class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;

  RetryInterceptor({
    required this.dio,
    this.maxRetries = 3,
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final requestOptions = err.requestOptions;

    // Retrieve previous retry count
    final retryCount = requestOptions.extra['retryCount'] ?? 0;

    if (_shouldRetry(err) && retryCount < maxRetries) {
      final nextRetryCount = retryCount + 1;
      requestOptions.extra['retryCount'] = nextRetryCount;

      // Exponential backoff delay calculation (e.g. 1s, 2s, 4s)
      final delaySeconds = (1 << nextRetryCount);
      print("🔄 [NETWORK RETRY] Attempt $nextRetryCount/$maxRetries for ${requestOptions.uri}. Retrying in ${delaySeconds}s...");
      await Future.delayed(Duration(seconds: delaySeconds));

      // On final retry, swap host to backup failover endpoint
      if (nextRetryCount == maxRetries) {
        final currentUrl = requestOptions.baseUrl;
        final backupUrl = AppConfig.backupUrl;
        if (currentUrl != backupUrl) {
          print("⚠️ [HOST FAILOVER] High congestion or timeout. Swapping host to backup: $backupUrl");
          requestOptions.baseUrl = backupUrl;
        }
      }

      try {
        // Re-execute exact request
        final response = await dio.fetch(requestOptions);
        return handler.resolve(response);
      } on DioException catch (retryErr) {
        // Bubble up error to next retry loop
        return super.onError(retryErr, handler);
      }
    }

    return super.onError(err, handler);
  }

  bool _shouldRetry(DioException err) {
    // Retry on timeouts, connection issues, or Render cold-start/temporary errors (503 Service Unavailable)
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError ||
        (err.response?.statusCode == 503) ||
        (err.error is SocketException);
  }
}
