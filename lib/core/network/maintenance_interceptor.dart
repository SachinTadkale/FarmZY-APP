/// Module: Maintenance Interceptor
/// Purpose: Detects 503 MAINTENANCE_MODE responses from the backend and
///          triggers a global maintenance state, redirecting the user to
///          the MaintenanceScreen regardless of which API call triggered it.
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farmzy/features/maintenance/providers/maintenance_provider.dart';

class MaintenanceInterceptor extends Interceptor {
  final Ref ref;

  MaintenanceInterceptor(this.ref);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final response = err.response;

    if (response != null && response.statusCode == 503) {
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final code = data['code'] as String?;

        if (code == 'MAINTENANCE_MODE') {
          // Set global maintenance state — router will redirect to /maintenance
          ref.read(maintenanceProvider.notifier).setMaintenance(true);
        }

        if (code == 'READ_ONLY_MODE') {
          ref.read(maintenanceProvider.notifier).setReadOnly(true);
        }
      }
    }

    handler.next(err);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // IMPORTANT: Do NOT clear maintenance state here. 
    // Maintenance state should only be cleared by a deliberate check (like AppConfig)
    // or when the system is actually back.
    handler.next(response);
  }
}
