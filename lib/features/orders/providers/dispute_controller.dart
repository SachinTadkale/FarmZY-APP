/**
 * Module: Dispute Controller
 * Purpose: Implements B2B dispute escalation provider and state management for Flutter.
 */
import 'package:farmzy/features/orders/data/dispute_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final disputeControllerProvider =
    StateNotifierProvider<DisputeController, AsyncValue<String?>>((ref) {
  return DisputeController(ref);
});

class DisputeController extends StateNotifier<AsyncValue<String?>> {
  final Ref _ref;

  DisputeController(this._ref) : super(const AsyncValue.data(null));

  /// Submit dispute for arbitration.
  Future<void> raiseDispute({
    required String orderId,
    required String reason,
    required String description,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final message = await _ref.read(disputeRepositoryProvider).raiseDispute(
            orderId: orderId,
            reason: reason,
            description: description,
          );
      return message;
    });
  }

  /// Reset provider state.
  void clear() {
    state = const AsyncValue.data(null);
  }
}
