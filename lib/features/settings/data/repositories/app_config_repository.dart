import 'package:dio/dio.dart';
import 'package:farmzy/core/network/dio_provider.dart';
import 'package:farmzy/features/settings/data/models/app_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppConfigRepository {
  final Dio _dio;

  AppConfigRepository(this._dio);

  Future<AppConfig> fetchConfig() async {
    try {
      final response = await _dio.get('/app-config');
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        return AppConfig.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      
      return AppConfig.fallback();
    } on DioException catch (e) {
      // ── Handle Maintenance Mode in 503 Error Body ──────────────────────────
      // When the server is in maintenance, even /app-config returns 503.
      // We must extract the maintenance flag from the error response to
      // prevent the app from defaulting to 'false' in its fallback.
      final response = e.response;
      if (response != null && response.statusCode == 503) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['maintenance'] == true) {
          return AppConfig(
            maintenanceMode: true,
            readOnlyMode:    data['readOnly'] ?? false,
            features:        AppConfig.fallback().features, // Use fallback features
            cachedAt:        DateTime.now(),
          );
        }
      }

      // Return safe fallback on other errors
      return AppConfig.fallback();
    } catch (e) {
      return AppConfig.fallback();
    }
  }
}

final appConfigRepositoryProvider = Provider<AppConfigRepository>((ref) {
  return AppConfigRepository(ref.watch(dioProvider));
});
