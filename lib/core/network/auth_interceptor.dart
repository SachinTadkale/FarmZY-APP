/**
 * Module: Auth Interceptor
 * Purpose: Implements the Auth Interceptor module for the FarmZy mobile app.
 * Note: Documentation-only change; behavior remains unchanged.
 */
import 'package:dio/dio.dart';
import 'package:farmzy/core/storage/secure_storage_service.dart';
import 'dart:async';

/**
 * Auth Interceptor.
 */
class AuthInterceptor extends Interceptor {
  final SecureStorageService storage;
  final Future<void> Function()? onUnauthorized;

  AuthInterceptor(this.storage, {this.onUnauthorized});

  @override
/**
 * On Request.
 */
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await storage.getToken();

    if (token != null && token.isNotEmpty) {
      options.headers["Authorization"] = "Bearer $token";
    }

    handler.next(options);
  }

  @override
/**
 * On Error.
 */
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      unawaited(storage.clearSession());
      unawaited(onUnauthorized?.call());
    }

    handler.next(err);
  }
}
