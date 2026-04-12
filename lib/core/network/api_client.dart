import 'package:dio/dio.dart';
import 'package:farmzy/core/network/auth_interceptor.dart';
import 'package:farmzy/core/storage/secure_storage_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.read(secureStorageServiceProvider);
  final dio = Dio(
    BaseOptions(
      baseUrl: 'http://10.0.2.2:5000/api/',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  dio.interceptors.add(AuthInterceptor(storage));

  return ApiClient(dio);
});

class ApiClient {
  final Dio dio;

  ApiClient(this.dio);

  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return dio.get(path, queryParameters: queryParameters);
  }

  Future<Response<dynamic>> post(String path, {dynamic data}) async {
    return dio.post(path, data: data);
  }

  Future<Response<dynamic>> postForm(
    String path, {
    required FormData data,
  }) async {
    return dio.post(path, data: data);
  }

  Future<Response<dynamic>> patch(String path, {dynamic data}) async {
    return dio.patch(path, data: data);
  }

  Future<Response<dynamic>> patchForm(
    String path, {
    required FormData data,
  }) async {
    return dio.patch(path, data: data);
  }

  Future<Response<dynamic>> delete(String path, {dynamic data}) async {
    return dio.delete(path, data: data);
  }
}
