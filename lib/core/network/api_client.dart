/// Module: Api Client
/// Purpose: Implements the Api Client module for the FarmZy mobile app.
/// Note: Documentation-only change; behavior remains unchanged.
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farmzy/core/network/dio_provider.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  final dio = ref.read(dioProvider);
  return ApiClient(dio);
});

/// Api Client.
class ApiClient {
  final Dio dio;

  ApiClient(this.dio);

  /// Helper to handle retries for cold starts (e.g. Railway)
  Future<Response<T>> _safeRequest<T>(Future<Response<T>> Function() request) async {
    try {
      return await request();
    } on DioException catch (e) {
      // Retry once if it's a timeout or connection error (possible cold start)
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        print("🔄 Cold start or timeout detected. Retrying in 5 seconds...");
        await Future.delayed(const Duration(seconds: 5));
        return await request();
      }
      rethrow;
    }
  }

  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return _safeRequest(() => dio.get(path, queryParameters: queryParameters));
  }

  Future<Response<dynamic>> post(String path, {dynamic data}) async {
    return _safeRequest(() => dio.post(path, data: data));
  }

  Future<Response<dynamic>> postForm(
    String path, {
    required FormData data,
  }) async {
    return _safeRequest(() => dio.post(path, data: data));
  }

  Future<Response<dynamic>> patch(String path, {dynamic data}) async {
    return _safeRequest(() => dio.patch(path, data: data));
  }

  Future<Response<dynamic>> patchForm(
    String path, {
    required FormData data,
  }) async {
    return _safeRequest(() => dio.patch(path, data: data));
  }

  Future<Response<dynamic>> delete(String path, {dynamic data}) async {
    return _safeRequest(() => dio.delete(path, data: data));
  }
}
