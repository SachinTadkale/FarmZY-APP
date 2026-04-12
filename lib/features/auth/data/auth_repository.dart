import 'package:farmzy/core/network/api_client.dart';
import 'package:farmzy/core/storage/secure_storage_service.dart';
import 'package:farmzy/features/auth/data/auth_service.dart';
import 'package:farmzy/features/auth/data/model/login_request.dart';
import 'package:farmzy/features/auth/data/model/otp_request.dart';
import 'package:farmzy/features/auth/data/model/register_request.dart';
import 'package:farmzy/features/auth/data/model/reset_password_request.dart';
import 'package:farmzy/shared/utils/jwt_parser.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Providers
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiClient = ref.read(apiClientProvider);
  final service = AuthService(apiClient);
  final storage = ref.read(secureStorageServiceProvider);

  return AuthRepository(service, storage);
});

class AuthRepository {
  final AuthService _service;
  final SecureStorageService _storage;

  AuthRepository(this._service, this._storage);

  Future<void> login(LoginRequest request) async {
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
    await _storage.saveSession(
      userId: payload['userId'],
      role: payload['role'],
      actorType: payload['actorType'],
      email: request.email,
      verificationStatus: 'VERIFIED',
    );
  }

  Future<String> requestOtp(OtpRequest request) async {
    final res = await _service.requestOtp(request);
    return res.message.isNotEmpty ? res.message : 'OTP sent successfully.';
  }

  Future<void> loginWithOtp(OtpRequest request) async {
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
    await _storage.saveSession(
      userId: payload['userId'],
      role: payload['role'],
      actorType: payload['actorType'],
      email: request.email,
      verificationStatus: 'VERIFIED',
    );
  }

  Future<void> register(RegisterRequest request) async {
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
      role: payload['role'],
      actorType: payload['actorType'],
      name: request.name,
      email: request.email,
      verificationStatus: 'PENDING',
    );
  }

  Future<String> forgotPassword(OtpRequest request) async {
    final res = await _service.forgotPassword(request);
    return res.message.isNotEmpty ? res.message : 'OTP sent successfully.';
  }

  Future<String> resetPassword(ResetPasswordRequest request) async {
    final res = await _service.resetPassword(request);
    return res.message.isNotEmpty
        ? res.message
        : 'Password reset successful.';
  }

  Future<void> logout() async {
    await _storage.deleteToken();
  }
}
