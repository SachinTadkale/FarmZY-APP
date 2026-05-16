/**
 * Module: Register Flow Repository
 * Purpose: Implements the Register Flow Repository module for the FarmZy mobile app.
 * Note: Documentation-only change; behavior remains unchanged.
 */
import 'package:dio/dio.dart';
import 'package:farmzy/core/network/api_client.dart';
import 'package:farmzy/features/auth/data/model/auth_response.dart';
import 'package:farmzy/features/auth/data/model/bank_details_request.dart';
import 'package:farmzy/features/auth/data/model/delivery_kyc_request.dart';
import 'package:farmzy/features/auth/data/model/farm_request.dart';
import 'package:farmzy/features/auth/data/model/kyc_request.dart';
import 'package:farmzy/features/auth/data/model/register_request.dart';
import 'package:farmzy/features/auth/data/model/vehicle_profile_request.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final registerFlowRepositoryProvider = Provider<RegisterFlowRepository>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return RegisterFlowRepository(apiClient);
});

/**
 * Register Flow Repository.
 */
class RegisterFlowRepository {
  final ApiClient _apiClient;

  RegisterFlowRepository(this._apiClient);

/**
 * Register.
 */
  Future<AuthResponse> register(RegisterRequest request) async {
    final response = await _apiClient.post(
      'auth/user/register',
      data: request.toJson(),
    );
    return AuthResponse.fromJson(response.data);
  }

/**
 * Add Farm.
 */
  Future<void> addFarm({
    required String token,
    required FarmRequest request,
  }) async {
    // Use the onboarding token from registration without logging the user in yet.
    await _apiClient.dio.post(
      'farms/',
      data: request.toJson(),
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

/**
 * Add Vehicle Profile.
 */
  Future<void> addVehicleProfile({
    required String token,
    required VehicleProfileRequest request,
  }) async {
    await _apiClient.dio.post(
      'delivery-partners/profile',
      data: request.toJson(),
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

/**
 * Add Bank.
 */
  Future<void> addBank({
    required String token,
    required BankDetailsRequest request,
  }) async {
    await _apiClient.dio.post(
      'banks/',
      data: request.toJson(),
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

/**
 * Upload Kyc.
 */
  Future<void> uploadKyc({
    required String token,
    required KycRequest request,
  }) async {
    // KYC is multipart because the backend expects uploaded files.
    final formData = FormData.fromMap({
      'docType': request.docType,
      'docNo': request.docNo,
      'frontImage': await MultipartFile.fromFile(request.frontImage.path),
      if (request.backImage != null)
        'backImage': await MultipartFile.fromFile(request.backImage!.path),
    });

    await _apiClient.dio.post(
      'kyc-records/',
      data: formData,
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'multipart/form-data',
        },
      ),
    );
  }

/**
 * Upload Delivery Kyc.
 */
  Future<void> uploadDeliveryKyc({
    required String token,
    required DeliveryKycRequest request,
  }) async {
    final formData = FormData.fromMap({
      'idType': request.idType,
      'idNumber': request.idNumber,
      'idFrontImage': await MultipartFile.fromFile(request.idFrontImage.path),
      if (request.idBackImage != null)
        'idBackImage': await MultipartFile.fromFile(request.idBackImage!.path),
      'drivingLicenseImage':
          await MultipartFile.fromFile(request.drivingLicenseImage.path),
      'rcImage': await MultipartFile.fromFile(request.rcImage.path),
    });

    await _apiClient.dio.post(
      'delivery-kyc-records/',
      data: formData,
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'multipart/form-data',
        },
      ),
    );
  }
}
