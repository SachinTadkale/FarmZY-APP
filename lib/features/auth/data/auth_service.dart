import 'package:farmzy/core/network/api_client.dart';
import 'package:farmzy/features/auth/data/model/auth_response.dart';
import 'package:farmzy/features/auth/data/model/login_request.dart';
import 'package:farmzy/features/auth/data/model/otp_request.dart';
import 'package:farmzy/features/auth/data/model/register_request.dart';
import 'package:farmzy/features/auth/data/model/reset_password_request.dart';

class AuthService {
  final ApiClient _api;
  AuthService(this._api);

  Future<AuthResponse> login(LoginRequest request) async {
    final res = await _api.post(
      'auth/user/login',
      data: request.toJson(),
    );
    return AuthResponse.fromJson(res.data);
  }

  Future<AuthResponse> requestOtp(OtpRequest request) async {
    final res = await _api.post(
      'auth/user/requestOtp',
      data: request.toJson(),
    );
    return AuthResponse.fromJson(res.data);
  }

  Future<AuthResponse> loginWithOtp(OtpRequest request) async {
    final res = await _api.post(
      'auth/user/loginWithOtp',
      data: request.toJson(),
    );
    return AuthResponse.fromJson(res.data);
  }

  Future<AuthResponse> forgotPassword(OtpRequest request) async {
    final res = await _api.post(
      'auth/user/forgotPassword',
      data: request.toJson(),
    );
    return AuthResponse.fromJson(res.data);
  }

  Future<AuthResponse> resetPassword(ResetPasswordRequest request) async {
    final res = await _api.post(
      'auth/user/resetPassword',
      data: request.toJson(),
    );
    return AuthResponse.fromJson(res.data);
  }

  Future<AuthResponse> register(RegisterRequest request) async {
    final res = await _api.post(
      'auth/user/register',
      data: request.toJson(),
    );
    return AuthResponse.fromJson(res.data);
  }
}
