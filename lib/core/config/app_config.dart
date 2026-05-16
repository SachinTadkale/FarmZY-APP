import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get baseUrl {
    final envUrl = dotenv.env['API_BASE_URL'];

    if (envUrl != null && envUrl.isNotEmpty) {
      // Ensure it ends with exactly one slash
      return '${envUrl.replaceAll(RegExp(r'/+$'), '')}/';
    }

    if (!kReleaseMode) {
      // Default local development URL for Android Emulator
      return "http://10.0.2.2:5000/api/v1/";
    }

    throw Exception("API_BASE_URL is not configured in .env file");
  }
}
