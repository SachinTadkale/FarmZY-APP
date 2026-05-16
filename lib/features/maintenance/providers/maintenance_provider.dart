/// Module: Maintenance Provider
/// Purpose: Tracks global maintenance and read-only state.
///          Updated by MaintenanceInterceptor when backend returns 503.
///          Watched by the GoRouter to redirect to /maintenance.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class MaintenanceState {
  final bool isInMaintenance;
  final bool isReadOnly;

  const MaintenanceState({
    this.isInMaintenance = false,
    this.isReadOnly = false,
  });

  MaintenanceState copyWith({bool? isInMaintenance, bool? isReadOnly}) {
    return MaintenanceState(
      isInMaintenance: isInMaintenance ?? this.isInMaintenance,
      isReadOnly: isReadOnly ?? this.isReadOnly,
    );
  }
}

class MaintenanceNotifier extends StateNotifier<MaintenanceState> {
  MaintenanceNotifier() : super(const MaintenanceState());

  void setMaintenance(bool value) {
    state = state.copyWith(isInMaintenance: value);
  }

  void setReadOnly(bool value) {
    state = state.copyWith(isReadOnly: value);
  }
}

final maintenanceProvider =
    StateNotifierProvider<MaintenanceNotifier, MaintenanceState>((ref) {
  return MaintenanceNotifier();
});
