import 'package:dio/dio.dart';
import 'package:farmzy/core/network/api_client.dart';
import 'package:farmzy/features/auth/data/model/auth_response.dart';
import 'package:farmzy/features/auth/data/model/bank_details_request.dart';
import 'package:farmzy/features/auth/data/model/farm_request.dart';
import 'package:farmzy/features/auth/data/model/kyc_request.dart';
import 'package:farmzy/features/auth/data/model/register_request.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final registerFlowRepositoryProvider = Provider<RegisterFlowRepository>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return RegisterFlowRepository(apiClient);
});

class RegisterFlowRepository {
  final ApiClient _apiClient;

  RegisterFlowRepository(this._apiClient);

  Future<AuthResponse> register(RegisterRequest request) async {
    final response = await _apiClient.post(
      'auth/user/register',
      data: request.toJson(),
    );
    return AuthResponse.fromJson(response.data);
  }

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
}
