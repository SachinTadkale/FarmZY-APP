import 'package:dio/dio.dart';
import 'package:farmzy/features/auth/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/**
 * Lang Interceptor.
 * Automatically adds the 'x-lang' header to every outgoing request
 * based on the currently selected language in the app.
 */
class LangInterceptor extends Interceptor {
  final Ref ref;

  LangInterceptor(this.ref);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Get the current locale from our provider
    final locale = ref.read(languageProvider);
    
    // Default to 'en' if not set
    final langCode = locale?.languageCode ?? 'en';
    
    options.headers['x-lang'] = langCode;
    
    handler.next(options);
  }
}
