import 'dart:async';
import 'package:dio/dio.dart';
import 'package:farmzy/core/config/app_config.dart' as CoreConfig;
import 'package:farmzy/features/settings/data/models/app_config.dart';
import 'package:farmzy/features/settings/data/repositories/app_config_repository.dart';
import 'package:farmzy/features/maintenance/providers/maintenance_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

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
  IO.Socket? _socket;

  AppConfigNotifier(this._repository, this._ref)
      : super(AppConfigState(
          config: AppConfig.fallback(),
          isInitialized: true,
        )) {
    fetchConfig();
    _initSocket();
    // Periodic self-healing fallback TTL (Refinement #10) shortened to 30 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) => fetchConfig());
  }

  void _initSocket() {
    try {
      // Extract base server URL by removing the /api/v1/ prefix
      final String baseOrigin = CoreConfig.AppConfig.baseUrl
          .replaceAll('/api/v1/', '')
          .replaceAll('/api/v1', '');

      print("🔌 Initializing AppConfig Socket.IO client at: $baseOrigin");

      _socket = IO.io(
        baseOrigin,
        IO.OptionBuilder()
            .setTransports(['websocket']) // Force high-performance Websocket transport
            .enableAutoConnect()
            .build(),
      );

      _socket?.onConnect((_) {
        print("🔌 Mobile AppConfig Socket.IO connected successfully!");
      });

      _socket?.onDisconnect((reason) {
        print("🔌 Mobile AppConfig Socket.IO disconnected: $reason");
      });

      _socket?.onConnectError((err) {
        print("🔌 Mobile AppConfig Socket.IO connection error: $err");
      });

      // Handle the global settings mutation event
      _socket?.on("system-settings-updated", (payload) {
        print("🔌 Mobile AppConfig received 'system-settings-updated' invalidation broadcast: $payload");
        fetchConfig();
      });
    } catch (e) {
      print("🔌 Mobile AppConfig Socket.IO failed to initialize: $e");
    }
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
    _socket?.disconnect();
    _socket?.dispose();
    super.dispose();
  }
}

final appConfigProvider = StateNotifierProvider<AppConfigNotifier, AppConfigState>((ref) {
  final repository = ref.watch(appConfigRepositoryProvider);
  return AppConfigNotifier(repository, ref);
});
