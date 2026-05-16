import 'package:dio/dio.dart';

extension DioRetry on Dio {
  /// A safe GET wrapper that attempts a single retry after a delay if the first call fails.
  /// Useful for handling "cold start" issues on backend services like Railway/Render.
  Future<Response<T>> safeGet<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onReceiveProgress,
  }) async {
    try {
      return await get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
    } catch (e) {
      // Wait for 2 seconds before retrying
      await Future.delayed(const Duration(seconds: 2));
      return await get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
    }
  }
}
