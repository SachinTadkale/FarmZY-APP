import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

class SecureStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const _tokenKey = 'auth_token';
  static const _userIdKey = 'auth_user_id';
  static const _roleKey = 'auth_role';
  static const _actorTypeKey = 'auth_actor_type';
  static const _nameKey = 'auth_name';
  static const _emailKey = 'auth_email';
  static const _verificationStatusKey = 'auth_verification_status';
  static const _registrationStepKey = 'auth_registration_step';
  static const _onboardingCompletedKey = 'auth_onboarding_completed';

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> saveSession({
    String? userId,
    String? role,
    String? actorType,
    String? name,
    String? email,
    String? verificationStatus,

    int? registrationStep,
    bool? onboardingCompleted,
  }) async {
    if (userId != null) {
      await _storage.write(key: _userIdKey, value: userId);
    }
    if (role != null) {
      await _storage.write(key: _roleKey, value: role);
    }
    if (actorType != null) {
      await _storage.write(key: _actorTypeKey, value: actorType);
    }
    if (name != null) {
      await _storage.write(key: _nameKey, value: name);
    }
    if (email != null) {
      await _storage.write(key: _emailKey, value: email);
    }
    if (verificationStatus != null) {
      await _storage.write(
        key: _verificationStatusKey,
        value: verificationStatus,
      );
    }

    if (registrationStep != null) {
      await _storage.write(
        key: _registrationStepKey,
        value: registrationStep.toString(),
      );
    }

    if (onboardingCompleted != null) {
      await _storage.write(
        key: _onboardingCompletedKey,
        value: onboardingCompleted.toString(),
      );
    }
  }

  Future<Map<String, dynamic>> getSession() async {
    final values = await Future.wait([
      _storage.read(key: _userIdKey),
      _storage.read(key: _roleKey),
      _storage.read(key: _actorTypeKey),
      _storage.read(key: _nameKey),
      _storage.read(key: _emailKey),
      _storage.read(key: _verificationStatusKey),
      _storage.read(key: _registrationStepKey),
      _storage.read(key: _onboardingCompletedKey),
    ]);

    return {
      'userId': values[0],
      'role': values[1],
      'actorType': values[2],
      'name': values[3],
      'email': values[4],
      'verificationStatus': values[5],
      'registrationStep': int.tryParse(values[6] ?? '0') ?? 0,
      'onboardingCompleted': (values[7] ?? 'false') == 'true',
    };
  }

  Future<void> clearSession() async {
    await _storage.deleteAll();
  }

}
