import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get baseUrl {
    final envUrl = dotenv.env['API_BASE_URL'];

    if (envUrl != null && envUrl.isNotEmpty) {
      return '${envUrl.replaceAll(RegExp(r'/+$'), '')}/';
    }

    if (!kReleaseMode) {
      return "http://10.0.2.2:5000/api/v1/";
    }

    throw Exception("API_BASE_URL is not configured in .env file");
  }

  static String get backupUrl {
    final envBackupUrl = dotenv.env['API_BACKUP_URL'];

    if (envBackupUrl != null && envBackupUrl.isNotEmpty) {
      return '${envBackupUrl.replaceAll(RegExp(r'/+$'), '')}/';
    }

    return "https://farmzy-backup-prod.onrender.com/api/v1/";
  }

  static String get environment {
    return dotenv.env['ENVIRONMENT'] ?? 'development';
  }
}
