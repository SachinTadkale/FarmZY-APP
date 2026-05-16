/**
 * Module: Auth Service
 * Purpose: Implements the Auth Service module for the FarmZy mobile app.
 * Note: Documentation-only change; behavior remains unchanged.
 */
import 'package:farmzy/core/network/api_client.dart';
import 'package:farmzy/features/auth/data/login_response.dart';
import 'package:farmzy/features/auth/data/model/login_request.dart';
import 'package:farmzy/features/auth/data/model/otp_request.dart';
import 'package:farmzy/features/auth/data/model/register_request.dart';
import 'package:farmzy/features/auth/data/model/reset_password_request.dart';

/**
 * Auth Service.
 */
class AuthService {
  final ApiClient _api;
  AuthService(this._api);

  Future<Map<String, dynamic>> me() async {
    final res = await _api.get('auth/user/me');
    final data = res.data;
    if (data is Map<String, dynamic>) {
      return data;
    }
    return const {};
  }

/**
 * Login.
 */
  Future<LoginResponse> login(LoginRequest request) async {
    final res = await _api.post(
      'auth/user/login',
      data: request.toJson(),
    );
    return LoginResponse.fromJson(res.data);
  }

/**
 * Request Otp.
 */
  Future<LoginResponse> requestOtp(OtpRequest request) async {
    final res = await _api.post(
      'auth/user/request-otp',
      data: request.toJson(),
    );
    return LoginResponse.fromJson(res.data);
  }

/**
 * Login With Otp.
 */
  Future<LoginResponse> loginWithOtp(OtpRequest request) async {
    final res = await _api.post(
      'auth/user/login-with-otp',
      data: request.toJson(),
    );
    return LoginResponse.fromJson(res.data);
  }

/**
 * Forgot Password.
 */
  Future<LoginResponse> forgotPassword(OtpRequest request) async {
    final res = await _api.post(
      'auth/user/forgot-password',
      data: request.toJson(),
    );
    return LoginResponse.fromJson(res.data);
  }

/**
 * Reset Password.
 */
  Future<LoginResponse> resetPassword(ResetPasswordRequest request) async {
    final res = await _api.post(
      'auth/user/reset-password',
      data: request.toJson(),
    );
    return LoginResponse.fromJson(res.data);
  }

/**
 * Register.
 */
  Future<LoginResponse> register(RegisterRequest request) async {
    final res = await _api.post(
      'auth/user/register',
      data: request.toJson(),
    );
    return LoginResponse.fromJson(res.data);
  }
}
