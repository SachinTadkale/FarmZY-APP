/**
 * Module: Auth Repository
 * Purpose: Implements the Auth Repository module for the FarmZy mobile app.
 * Note: Documentation-only change; behavior remains unchanged.
 */
import 'package:farmzy/core/network/api_client.dart';
import 'package:farmzy/core/storage/secure_storage_service.dart';
import 'package:farmzy/features/auth/data/auth_service.dart';
import 'package:farmzy/features/auth/data/model/auth_session.dart';
import 'package:farmzy/features/auth/data/login_response.dart';
import 'package:farmzy/features/auth/data/model/login_request.dart';
import 'package:farmzy/features/auth/data/model/otp_request.dart';
import 'package:farmzy/features/auth/data/model/register_request.dart';
import 'package:farmzy/features/auth/data/model/reset_password_request.dart';
import 'package:farmzy/shared/enums/user_role.dart';
import 'package:farmzy/shared/utils/jwt_parser.dart';
import 'package:farmzy/shared/enums/verification_status.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Providers
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiClient = ref.read(apiClientProvider);
  final service = AuthService(apiClient);
  final storage = ref.read(secureStorageServiceProvider);

  return AuthRepository(service, storage);
});

/**
 * Auth Repository.
 */
class AuthRepository {
  final AuthService _service;
  final SecureStorageService _storage;

  AuthRepository(this._service, this._storage);

/**
 * Login.
 */
  Future<LoginResponse> login(LoginRequest request) async {
    final res = await _service.login(request);

    if (res.token.isEmpty) {
      throw Exception(
        res.message.isNotEmpty
            ? res.message
            : 'Login succeeded but no auth token was returned.',
      );
    }

    await _storage.saveToken(res.token);
    final payload = JwtParser.parse(res.token);
    final role = UserRole.fromApiValue(res.role);
    await _storage.saveSession(
      userId: payload['userId'],
      role: role,
      actorType: payload['actorType'],
      email: request.email,
      verificationStatus:
          res.verificationStatus == 'APPROVED'
              ? VerificationStatus.approved
              : res.verificationStatus == 'UNDER_REVIEW'
              ? VerificationStatus.underReview
              : VerificationStatus.fromApiValue(res.verificationStatus),
      registrationStep: res.registrationStep,
      onboardingCompleted: res.onboardingCompleted,
    );
    return res;
  }

/**
 * Request Otp.
 */
  Future<String> requestOtp(OtpRequest request) async {
    final res = await _service.requestOtp(request);
    return res.message.isNotEmpty ? res.message : 'OTP sent successfully.';
  }

/**
 * Login With Otp.
 */
  Future<LoginResponse> loginWithOtp(OtpRequest request) async {
    final res = await _service.loginWithOtp(request);

    if (res.token.isEmpty) {
      throw Exception(
        res.message.isNotEmpty
            ? res.message
            : 'OTP login succeeded but no auth token was returned.',
      );
    }

    await _storage.saveToken(res.token);
    final payload = JwtParser.parse(res.token);
    final role = UserRole.fromApiValue(res.role);
    await _storage.saveSession(
      userId: payload['userId'],
      role: role,
      actorType: payload['actorType'],
      email: request.email,
      verificationStatus: VerificationStatus.fromApiValue(res.verificationStatus),
      registrationStep: res.registrationStep,
      onboardingCompleted: res.onboardingCompleted,
    );
    return res;
  }

/**
 * Register.
 */
  Future<LoginResponse> register(RegisterRequest request) async {
    final res = await _service.register(request);

    if (res.token.isEmpty) {
      throw Exception(
        res.message.isNotEmpty
            ? res.message
            : 'Registration succeeded but no auth token was returned.',
      );
    }

    await _storage.saveToken(res.token);
    final payload = JwtParser.parse(res.token);
    await _storage.saveSession(
      userId: payload['userId'],
      role: request.role,
      actorType: payload['actorType'],
      name: request.name,
      email: request.email,
      verificationStatus: VerificationStatus.fromApiValue(res.verificationStatus),
      registrationStep: res.registrationStep,
      onboardingCompleted: res.onboardingCompleted,
    );
    return res;
  }

/**
 * Me.
 */
  Future<AuthSession> me() async {
    final data = await _service.me();
    return AuthSession.fromJson(data);
  }

/**
 * Forgot Password.
 */
  Future<String> forgotPassword(OtpRequest request) async {
    final res = await _service.forgotPassword(request);
    return res.message.isNotEmpty ? res.message : 'OTP sent successfully.';
  }

/**
 * Reset Password.
 */
  Future<String> resetPassword(ResetPasswordRequest request) async {
    final res = await _service.resetPassword(request);
    return res.message.isNotEmpty ? res.message : 'Password reset successful.';
  }

/**
 * Logout.
 */
  Future<void> logout() async {
    await _storage.clearSession();
  }
}
