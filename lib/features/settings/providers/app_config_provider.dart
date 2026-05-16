import 'dart:async';
import 'package:dio/dio.dart';
import 'package:farmzy/features/settings/data/models/app_config.dart';
import 'package:farmzy/features/settings/data/repositories/app_config_repository.dart';
import 'package:farmzy/features/maintenance/providers/maintenance_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class AppConfigState {
  final AppConfig config;
  final bool isLoading;
  final bool isInitialized;

  const AppConfigState({
    required this.config,
    this.isLoading = false,
    this.isInitialized = false,
  });

  AppConfigState copyWith({AppConfig? config, bool? isLoading, bool? isInitialized}) {
    return AppConfigState(
      config:        config ?? this.config,
      isLoading:     isLoading ?? this.isLoading,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

class AppConfigNotifier extends StateNotifier<AppConfigState> {
  final AppConfigRepository _repository;
  final Ref _ref;
  Timer? _refreshTimer;

  AppConfigNotifier(this._repository, this._ref)
      : super(AppConfigState(config: AppConfig.fallback())) {
    fetchConfig();
    // Refresh config every 5 minutes
    _refreshTimer = Timer.periodic(const Duration(minutes: 5), (_) => fetchConfig());
  }

  Future<void> fetchConfig() async {
    state = state.copyWith(isLoading: true);
    try {
      final newConfig = await _repository.fetchConfig();
      state = state.copyWith(config: newConfig, isLoading: false, isInitialized: true);
      
      // Synchronize with global maintenance state
      _ref.read(maintenanceProvider.notifier).setMaintenance(newConfig.maintenanceMode);
      _ref.read(maintenanceProvider.notifier).setReadOnly(newConfig.readOnlyMode);
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 503) {
        final data = e.response?.data;
        if (data is Map<String, dynamic> && (data['code'] == 'MAINTENANCE_MODE' || data['code'] == 'READ_ONLY_MODE')) {
          _ref.read(maintenanceProvider.notifier).setMaintenance(true);
          if (data['code'] == 'READ_ONLY_MODE') {
             _ref.read(maintenanceProvider.notifier).setReadOnly(true);
          }
        }
      }
      state = state.copyWith(isLoading: false, isInitialized: true);
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}

final appConfigProvider = StateNotifierProvider<AppConfigNotifier, AppConfigState>((ref) {
  final repository = ref.watch(appConfigRepositoryProvider);
  return AppConfigNotifier(repository, ref);
});
