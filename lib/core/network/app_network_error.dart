import 'package:dio/dio.dart';

class AppNetworkError {
  static String userMessage(Object error) {
    if (error is DioException) {
      final serverMessage = _serverMessage(error);
      if (serverMessage != null && serverMessage.isNotEmpty) {
        return serverMessage;
      }

      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'The server is taking too long to respond. Please try again later.';
        case DioExceptionType.connectionError:
          return 'We could not reach the server. Check your internet connection and try again later.';
        case DioExceptionType.badCertificate:
          return 'A secure connection could not be established. Please try again.';
        case DioExceptionType.cancel:
          return 'The request was cancelled. Please try again.';
        case DioExceptionType.badResponse:
          return _statusMessage(error.response?.statusCode);
        case DioExceptionType.unknown:
          return 'Something went wrong while contacting the server. Please try again later.';
      }
    }

    final message = error.toString().trim();
    if (message.startsWith('Exception: ')) {
      return message.substring('Exception: '.length).trim();
    }
    return message.isEmpty
        ? 'Something went wrong. Please try again later.'
        : message;
  }

  static String _statusMessage(int? statusCode) {
    if (statusCode == null) {
      return 'The server returned an unexpected response. Please try again later.';
    }

    if (statusCode >= 500) {
      return 'The server is having trouble right now. Please try again later.';
    }

    if (statusCode == 404) {
      return 'The requested data could not be found.';
    }

    if (statusCode == 401 || statusCode == 403) {
      return 'Your session has expired or access is not allowed. Please sign in again.';
    }

    if (statusCode == 429) {
      return 'Too many requests. Please wait a moment and try again.';
    }

    return 'We could not complete your request. Please try again later.';
  }

  static String? _serverMessage(DioException error) {
    final data = error.response?.data;

    if (data is Map<String, dynamic>) {
      final message = data['message'] ?? data['error'];
      if (message != null) {
        return message.toString();
      }
    }

    return null;
  }
}
