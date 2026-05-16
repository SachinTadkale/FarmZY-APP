/**
 * Module: Onboarding Controller
 * Purpose: Implements the Onboarding Controller module for the FarmZy mobile app.
 * Note: Documentation-only change; behavior remains unchanged.
 */
import 'package:dio/dio.dart';
import 'package:farmzy/features/auth/data/model/bank_details_request.dart';
import 'package:farmzy/features/auth/data/model/delivery_kyc_request.dart';
import 'package:farmzy/features/auth/data/model/farm_request.dart';
import 'package:farmzy/features/auth/data/model/kyc_request.dart';
import 'package:farmzy/features/auth/data/model/vehicle_profile_request.dart';
import 'package:farmzy/features/auth/data/register_flow_repository.dart';
import 'package:farmzy/features/auth/providers/auth_controller.dart';
import 'package:farmzy/features/auth/providers/auth_state.dart';
import 'package:farmzy/shared/enums/user_role.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final onboardingControllerProvider =
    StateNotifierProvider<OnboardingController, AsyncValue<void>>((ref) {
  final repository = ref.read(registerFlowRepositoryProvider);
  return OnboardingController(ref, repository);
});

/**
 * Onboarding Controller.
 */
class OnboardingController extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;
  final RegisterFlowRepository _repository;

  OnboardingController(this._ref, this._repository)
      : super(const AsyncData<void>(null));

  AuthState get _auth => _ref.read(authControllerProvider);
  String get _token {
    final token = _auth.token;
    if (token == null || token.isEmpty) {
      throw Exception('Session expired. Please log in again.');
    }
    return token;
  }

/**
 * Submit Farmer Farm Details.
 */
  Future<void> submitFarmerFarmDetails(FarmRequest request) async {
    state = const AsyncLoading<void>();
    try {
      await _repository.addFarm(token: _token, request: request);
      await _ref.read(authControllerProvider.notifier).updateRegistrationStep(
            2,
          );
      state = const AsyncData<void>(null);
    } on DioException catch (e, stackTrace) {
      state = AsyncError(_extractMessage(e), stackTrace);
    } catch (e, stackTrace) {
      state = AsyncError(Exception(e.toString()), stackTrace);
    }
  }

/**
 * Submit Delivery Vehicle Details.
 */
  Future<void> submitDeliveryVehicleDetails(
    VehicleProfileRequest request,
  ) async {
    state = const AsyncLoading<void>();
    try {
      await _repository.addVehicleProfile(token: _token, request: request);
      await _ref.read(authControllerProvider.notifier).updateRegistrationStep(
            2,
          );
      state = const AsyncData<void>(null);
    } on DioException catch (e, stackTrace) {
      state = AsyncError(_extractMessage(e), stackTrace);
    } catch (e, stackTrace) {
      state = AsyncError(Exception(e.toString()), stackTrace);
    }
  }

/**
 * Submit Bank Details.
 */
  Future<void> submitBankDetails(BankDetailsRequest request) async {
    state = const AsyncLoading<void>();
    try {
      await _repository.addBank(token: _token, request: request);
      await _ref.read(authControllerProvider.notifier).updateRegistrationStep(
            3,
          );
      state = const AsyncData<void>(null);
    } on DioException catch (e, stackTrace) {
      state = AsyncError(_extractMessage(e), stackTrace);
    } catch (e, stackTrace) {
      state = AsyncError(Exception(e.toString()), stackTrace);
    }
  }

/**
 * Submit Kyc Details.
 */
  Future<void> submitKycDetails(KycRequest request) async {
    state = const AsyncLoading<void>();
    try {
      if (_auth.role == UserRole.deliveryPartner) {
        throw Exception(
          'Use the delivery partner KYC upload for this onboarding flow.',
        );
      }

      await _repository.uploadKyc(token: _token, request: request);
      await _ref.read(authControllerProvider.notifier).completeOnboarding();
      state = const AsyncData<void>(null);
    } on DioException catch (e, stackTrace) {
      state = AsyncError(_extractMessage(e), stackTrace);
    } catch (e, stackTrace) {
      state = AsyncError(Exception(e.toString()), stackTrace);
    }
  }

/**
 * Submit Delivery Kyc Details.
 */
  Future<void> submitDeliveryKycDetails(DeliveryKycRequest request) async {
    state = const AsyncLoading();
    try {
      if (_auth.role != UserRole.deliveryPartner) {
        throw Exception('Use the farmer KYC upload for this onboarding flow.');
      }

      await _repository.uploadDeliveryKyc(token: _token, request: request);
      await _ref.read(authControllerProvider.notifier).completeOnboarding();
      state = const AsyncData(null);
    } on DioException catch (e, stackTrace) {
      state = AsyncError(_extractMessage(e), stackTrace);
    } catch (e, stackTrace) {
      state = AsyncError(Exception(e.toString()), stackTrace);
    }
  }

/**
 * Extract Message.
 */
  String _extractMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      return (data['message'] ?? data['error'] ?? 'Failed to submit step')
          .toString();
    }
    return e.message ?? 'Failed to submit step';
  }
}
