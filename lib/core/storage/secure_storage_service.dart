/**
 * Module: Secure Storage Service
 * Purpose: Implements the Secure Storage Service module for the FarmZy mobile app.
 * Note: Documentation-only change; behavior remains unchanged.
 */
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farmzy/shared/enums/user_role.dart';
import 'package:farmzy/shared/enums/verification_status.dart';

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

/**
 * Secure Storage Service.
 */
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
  static const _pendingRoleKey = 'auth_pending_role';
  static const _languageKey = 'app_language';
  static const _themeKey = 'app_theme';
  static const _hasSelectedLanguageKey = 'has_selected_language';

  /**
 * Save Token.
 */
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  /**
 * Get Token.
 */
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /**
 * Save Session.
 */
  Future<void> saveSession({
    String? userId,
    UserRole? role,
    String? actorType,
    String? name,
    String? email,
    VerificationStatus? verificationStatus,
    int? registrationStep,
    bool? onboardingCompleted,
  }) async {
    if (userId != null) {
      await _storage.write(key: _userIdKey, value: userId);
    }
    if (role != null) {
      await _storage.write(key: _roleKey, value: role.apiValue);
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
        value: verificationStatus.apiValue,
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

    if (kDebugMode) {
      debugPrint(
        '[SecureStorage] saveSession '
        'userId=$userId role=${role?.apiValue} '
        'verificationStatus=${verificationStatus?.apiValue} '
        'registrationStep=$registrationStep '
        'onboardingCompleted=$onboardingCompleted',
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

    final session = {
      'userId': values[0],
      'role': values[1],
      'actorType': values[2],
      'name': values[3],
      'email': values[4],
      'verificationStatus': values[5],
      'registrationStep': int.tryParse(values[6] ?? '0') ?? 0,
      'onboardingCompleted': (values[7] ?? 'false') == 'true',
    };

    if (kDebugMode) {
      debugPrint(
        '[SecureStorage] getSession '
        'userId=${session['userId']} role=${session['role']} '
        'verificationStatus=${session['verificationStatus']} '
        'registrationStep=${session['registrationStep']} '
        'onboardingCompleted=${session['onboardingCompleted']}',
      );
    }

    return session;
  }

  /**
 * Save Pending Role.
 */
  Future<void> savePendingRole(UserRole role) async {
    await _storage.write(key: _pendingRoleKey, value: role.apiValue);

    if (kDebugMode) {
      debugPrint('[SecureStorage] savePendingRole role=${role.apiValue}');
    }
  }

  /**
 * Get Pending Role.
 */
  Future<UserRole?> getPendingRole() async {
    final value = await _storage.read(key: _pendingRoleKey);
    if (value == null || value.isEmpty) {
      if (kDebugMode) {
        debugPrint('[SecureStorage] getPendingRole role=null');
      }
      return null;
    }
    final role = UserRole.fromApiValue(value);
    if (kDebugMode) {
      debugPrint('[SecureStorage] getPendingRole role=${role.apiValue}');
    }
    return role;
  }

  /**
 * Clear Pending Role.
 */
  Future<void> clearPendingRole() async {
    await _storage.delete(key: _pendingRoleKey);
  }

  /**
 * Clear Session.
 */
  Future<void> clearSession() async {
    await _storage.deleteAll();
  }

  Future<void> saveLanguage(String languageCode) async {
    await _storage.write(key: _languageKey, value: languageCode);
  }

  Future<String?> getLanguage() async {
    return await _storage.read(key: _languageKey);
  }

  Future<void> clearLanguage() async {
    await _storage.delete(key: _languageKey);
  }

  Future<void> saveTheme(String themeMode) async {
    await _storage.write(key: _themeKey, value: themeMode);
  }

  Future<String?> getTheme() async {
    return await _storage.read(key: _themeKey);
  }

  Future<void> setHasSelectedLanguage(bool hasSelected) async {
    await _storage.write(
      key: _hasSelectedLanguageKey,
      value: hasSelected.toString(),
    );
  }

  Future<bool> getHasSelectedLanguage() async {
    final value = await _storage.read(key: _hasSelectedLanguageKey);
    return value == 'true';
  }
}
