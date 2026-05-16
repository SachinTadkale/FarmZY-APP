/**
 * Module: Delivery Controller
 * Purpose: Implements the Delivery Controller module for the FarmZy mobile app.
 * Note: Documentation-only change; behavior remains unchanged.
 */
import 'package:flutter_riverpod/legacy.dart';

/**
 * Delivery State.
 */
class DeliveryState {
  final bool isAvailable;
  final bool isLoading;
  final int availableJobs;
  final int activeDeliveries;
  final double earnings;

  const DeliveryState({
    this.isAvailable = true,
    this.isLoading = false,
    this.availableJobs = 4,
    this.activeDeliveries = 2,
    this.earnings = 0,
  });

  DeliveryState copyWith({
    bool? isAvailable,
    bool? isLoading,
    int? availableJobs,
    int? activeDeliveries,
    double? earnings,
  }) {
    return DeliveryState(
      isAvailable: isAvailable ?? this.isAvailable,
      isLoading: isLoading ?? this.isLoading,
      availableJobs: availableJobs ?? this.availableJobs,
      activeDeliveries: activeDeliveries ?? this.activeDeliveries,
      earnings: earnings ?? this.earnings,
    );
  }
}

final deliveryControllerProvider =
    StateNotifierProvider<DeliveryController, DeliveryState>((ref) {
  return DeliveryController();
});

/**
 * Delivery Controller.
 */
class DeliveryController extends StateNotifier<DeliveryState> {
  DeliveryController() : super(const DeliveryState());

/**
 * Toggle Availability.
 */
  void toggleAvailability() {
    state = state.copyWith(isAvailable: !state.isAvailable);
  }

/**
 * Refresh Dashboard.
 */
  void refreshDashboard() {
    state = state.copyWith(isLoading: true);
    state = state.copyWith(isLoading: false);
  }
}
