import 'dart:async';

import 'package:farmzy/features/delivery_partner/data/delivery_models.dart';
import 'package:farmzy/features/delivery_partner/data/delivery_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class DeliveryState {
  final bool isLoading;
  final bool isRefreshing;
  final String? error;
  final DeliveryPartnerProfile? profile;
  final DeliveryDashboardSummary dashboard;
  final List<DeliveryJob> availableJobs;
  final List<DeliveryJob> activeDeliveries;

  const DeliveryState({
    this.isLoading = false,
    this.isRefreshing = false,
    this.error,
    this.profile,
    this.dashboard = const DeliveryDashboardSummary(availableJobs: 0, activeDeliveries: 0),
    this.availableJobs = const [],
    this.activeDeliveries = const [],
  });

  bool get isAvailable => profile?.isAvailable ?? false;

  DeliveryState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    String? error,
    DeliveryPartnerProfile? profile,
    DeliveryDashboardSummary? dashboard,
    List<DeliveryJob>? availableJobs,
    List<DeliveryJob>? activeDeliveries,
  }) {
    return DeliveryState(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      error: error,
      profile: profile ?? this.profile,
      dashboard: dashboard ?? this.dashboard,
      availableJobs: availableJobs ?? this.availableJobs,
      activeDeliveries: activeDeliveries ?? this.activeDeliveries,
    );
  }
}

final deliveryControllerProvider = StateNotifierProvider<DeliveryController, DeliveryState>((ref) {
  return DeliveryController(ref.read(deliveryRepositoryProvider))..bootstrap();
});

final deliveryWalletProvider = FutureProvider.autoDispose<DeliveryWallet>((ref) async {
  final repo = ref.watch(deliveryRepositoryProvider);
  return repo.getWallet();
});

final deliveryTransactionsProvider = FutureProvider.autoDispose<List<LogisticsTransaction>>((ref) async {
  final repo = ref.watch(deliveryRepositoryProvider);
  return repo.getTransactions();
});

final deliveryEarningsSummaryProvider = FutureProvider.autoDispose<Map<String, double>>((ref) async {
  final repo = ref.watch(deliveryRepositoryProvider);
  return repo.getEarningsSummary();
});

class DeliveryController extends StateNotifier<DeliveryState> {
  final DeliveryRepository _repository;
  Timer? _poller;

  DeliveryController(this._repository) : super(const DeliveryState());

  Future<void> bootstrap() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final results = await Future.wait([
        _repository.getProfile(),
        _repository.getDashboard(),
        _repository.getJobs(),
        _repository.getActiveDeliveries(),
      ]);

      state = state.copyWith(
        isLoading: false,
        profile: results[0] as DeliveryPartnerProfile,
        dashboard: results[1] as DeliveryDashboardSummary,
        availableJobs: results[2] as List<DeliveryJob>,
        activeDeliveries: results[3] as List<DeliveryJob>,
      );

      _poller?.cancel();
      _poller = Timer.periodic(const Duration(seconds: 15), (_) => refresh(silent: true));
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error.toString());
    }
  }

  Future<void> refresh({bool silent = false}) async {
    state = state.copyWith(isRefreshing: !silent, error: null);
    try {
      final results = await Future.wait([
        _repository.getDashboard(),
        _repository.getJobs(),
        _repository.getActiveDeliveries(),
      ]);

      state = state.copyWith(
        isRefreshing: false,
        dashboard: results[0] as DeliveryDashboardSummary,
        availableJobs: results[1] as List<DeliveryJob>,
        activeDeliveries: results[2] as List<DeliveryJob>,
      );
    } catch (error) {
      state = state.copyWith(isRefreshing: false, error: error.toString());
    }
  }

  Future<void> toggleAvailability() async {
    final nextValue = !state.isAvailable;
    final previous = state.profile;
    if (previous == null) return;

    state = state.copyWith(
      profile: DeliveryPartnerProfile(
        id: previous.id,
        vehicleType: previous.vehicleType,
        vehicleNumber: previous.vehicleNumber,
        licenseNumber: previous.licenseNumber,
        isAvailable: nextValue,
        isActive: previous.isActive,
      ),
    );

    try {
      final updated = await _repository.updateAvailability(nextValue);
      state = state.copyWith(profile: updated);
    } catch (error) {
      state = state.copyWith(profile: previous, error: error.toString());
    }
  }

  Future<void> acceptJob(String deliveryId) async {
    await _repository.acceptJob(deliveryId);
    await refresh();
  }

  Future<void> verifyPickup(String deliveryId, String otp) async {
    await _repository.updateStatus(deliveryId: deliveryId, status: 'PICKED_UP', pickupOtp: otp);
    await refresh();
  }

  Future<void> markInTransit(String deliveryId) async {
    await _repository.updateStatus(deliveryId: deliveryId, status: 'IN_TRANSIT');
    await refresh();
  }

  Future<void> verifyDelivery(String deliveryId, String otp) async {
    await _repository.updateStatus(deliveryId: deliveryId, status: 'DELIVERED', deliveryOtp: otp);
    await refresh();
  }

  @override
  void dispose() {
    _poller?.cancel();
    super.dispose();
  }
}
