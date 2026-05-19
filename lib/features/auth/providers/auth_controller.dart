/**
 * Module: Auth Controller
 * Purpose: Implements the Auth Controller module for the FarmZy mobile app.
 * Note: Documentation-only change; behavior remains unchanged.
 */
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:farmzy/core/storage/secure_storage_service.dart';
import 'package:farmzy/features/auth/data/auth_repository.dart';
import 'package:farmzy/features/auth/data/model/register_request.dart';
import 'package:farmzy/features/auth/data/model/login_request.dart';
import 'package:farmzy/features/auth/data/model/otp_request.dart';
import 'package:farmzy/features/auth/data/model/reset_password_request.dart';
import 'package:farmzy/features/auth/providers/auth_state.dart';
import 'package:farmzy/features/auth/providers/role_selection_provider.dart';
import 'package:farmzy/features/auth/providers/language_provider.dart';
import 'package:farmzy/shared/enums/user_role.dart';
import 'dart:ui';
import 'package:farmzy/shared/enums/verification_status.dart';
import 'package:farmzy/shared/utils/jwt_parser.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) {
    final repo = ref.read(authRepositoryProvider);
    return AuthController(ref, repo);
  },
);

/**
 * Auth Controller.
 */
class AuthController extends StateNotifier<AuthState> {
  final Ref _ref;
  final AuthRepository _repo;

  AuthController(this._ref, this._repo) : super(const AuthState());

/**
 * Login.
 */
  Future<void> login(
    String email,
    String password, {
    UserRole? role,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final res = await _repo.login(
        LoginRequest(email: email, password: password, role: role),
      );

      final finalRole = UserRole.fromApiValue(res.role);

      state = state.copyWith(
        token: res.token,
        role: finalRole,
        registrationStep: res.registrationStep,
        verificationStatus: VerificationStatus.fromApiValue(
          res.verificationStatus,
        ),
        onboardingCompleted: res.onboardingCompleted,
        isLoggedIn: true,
        isLoading: false,
        isInitialized: true,
        clearError: true,
      );
      _ref.read(selectedRoleProvider.notifier).state = finalRole;
      await _ref.read(secureStorageServiceProvider).clearPendingRole();
      if (kDebugMode) {
        debugPrint(
          '[AuthController] login '
          'role=${finalRole.apiValue} '
          'verificationStatus=${state.verificationStatus.apiValue} '
          'registrationStep=${state.registrationStep} '
          'onboardingCompleted=${state.onboardingCompleted}',
        );
      }
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        clearError: false,
        error: _extractError(e),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        clearError: false,
        error: e.toString(),
      );
    }
  }

/**
 * Login With Otp.
 */
  Future<void> loginWithOtp(
    String email,
    String otp, {
    UserRole? role,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final res = await _repo.loginWithOtp(
        OtpRequest(email: email, otp: otp, role: role),
      );

      final finalRole = UserRole.fromApiValue(res.role);

      state = state.copyWith(
        token: res.token,
        role: finalRole,
        registrationStep: res.registrationStep,
        verificationStatus: VerificationStatus.fromApiValue(
          res.verificationStatus,
        ),
        onboardingCompleted: res.onboardingCompleted,
        isLoggedIn: true,
        isLoading: false,
        isInitialized: true,
        clearError: true,
      );
      _ref.read(selectedRoleProvider.notifier).state = finalRole;
      await _ref.read(secureStorageServiceProvider).clearPendingRole();
      if (kDebugMode) {
        debugPrint(
          '[AuthController] loginWithOtp '
          'role=${finalRole.apiValue} '
          'verificationStatus=${state.verificationStatus.apiValue} '
          'registrationStep=${state.registrationStep} '
          'onboardingCompleted=${state.onboardingCompleted}',
        );
      }
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        clearError: false,
        error: _extractError(e),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        clearError: false,
        error: e.toString(),
      );
    }
  }

/**
 * Request Otp.
 */
  Future<void> requestOtp(String email, {UserRole? role}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _repo.requestOtp(OtpRequest(email: email, role: role));
      state = state.copyWith(isLoading: false, clearError: true);
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        clearError: false,
        error: _extractError(e),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        clearError: false,
        error: e.toString(),
      );
    }
  }

/**
 * Forgot Password.
 */
  Future<void> forgotPassword(String email, {UserRole? role}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _repo.forgotPassword(OtpRequest(email: email, role: role));
      state = state.copyWith(isLoading: false, clearError: true);
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        clearError: false,
        error: _extractError(e),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        clearError: false,
        error: e.toString(),
      );
    }
  }

/**
 * Reset Password.
 */
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
    required String confirmPassword,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _repo.resetPassword(
        ResetPasswordRequest(
          email: email,
          otp: otp,
          newPassword: newPassword,
          confirmPassword: confirmPassword,
        ),
      );

      state = state.copyWith(isLoading: false, clearError: true);
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        clearError: false,
        error: _extractError(e),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        clearError: false,
        error: e.toString(),
      );
    }
  }

/**
 * Register.
 */
  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String address,
    required String gender,
    required String password,
    required UserRole role,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final res = await _repo.register(
        RegisterRequest(
          name: name,
          email: email,
          phoneNo: phone,
          address: address,
          gender: gender,
          password: password,
          role: role,
        ),
      );

      final nextStep = res.registrationStep <= 0 ? 1 : res.registrationStep;
      final storage = _ref.read(secureStorageServiceProvider);
      await storage.saveSession(
        role: role,
        verificationStatus: VerificationStatus.fromApiValue(
          res.verificationStatus,
        ),
        registrationStep: nextStep,
        onboardingCompleted: res.onboardingCompleted,
      );
      state = state.copyWith(
        token: res.token,
        role: role,
        registrationStep: nextStep,
        verificationStatus: VerificationStatus.fromApiValue(
          res.verificationStatus,
        ),
        onboardingCompleted: res.onboardingCompleted,
        isLoggedIn: true,
        isLoading: false,
        isInitialized: true,
        clearError: true,
      );
      _ref.read(selectedRoleProvider.notifier).state = role;
      await _ref.read(secureStorageServiceProvider).clearPendingRole();
      if (kDebugMode) {
        debugPrint(
          '[AuthController] register '
          'role=${role.apiValue} '
          'verificationStatus=${state.verificationStatus.apiValue} '
          'registrationStep=${state.registrationStep} '
          'onboardingCompleted=${state.onboardingCompleted}',
        );
      }
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        clearError: false,
        error: _extractError(e),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        clearError: false,
        error: e.toString(),
      );
    }
  }

/**
 * Restore Session.
 */
  Future<void> restoreSession() async {
    final storage = _ref.read(secureStorageServiceProvider);
    final token = await storage.getToken();
    final session = await storage.getSession();
    final pendingRole = await storage.getPendingRole();
    final languageCode = await storage.getLanguage();

    if (languageCode != null) {
      _ref.read(languageProvider.notifier).state = Locale(languageCode);
    }

    if (token == null || token.isEmpty) {
      _ref.read(selectedRoleProvider.notifier).state =
          pendingRole ?? UserRole.farmer;
      state = AuthState(
        role: pendingRole ?? UserRole.farmer,
        isInitialized: true,
      );
      return;
    }

    final decoded = _decodeRoleFromToken(token);
    final localRole = decoded ?? UserRole.fromApiValue(session['role']);
    final localVerificationStatus = VerificationStatus.fromApiValue(
      session['verificationStatus']?.toString(),
    );
    final localRegistrationStep = session['registrationStep'] ?? 0;
    final localOnboardingCompleted = session['onboardingCompleted'] ?? false;

    state = AuthState(
      token: token,
      role: localRole,
      registrationStep: localRegistrationStep,
      verificationStatus: localVerificationStatus,
      onboardingCompleted: localOnboardingCompleted,
      isLoggedIn: true,
      isLoading: false,
      isInitialized: true,
    );
    _ref.read(selectedRoleProvider.notifier).state = localRole;

    if (kDebugMode) {
      debugPrint(
        '[AuthController] restoreSession '
        'tokenPresent=${token.isNotEmpty} '
        'role=${localRole.apiValue} '
        'verificationStatus=${localVerificationStatus.apiValue} '
        'registrationStep=$localRegistrationStep '
        'onboardingCompleted=$localOnboardingCompleted',
      );
    }

    // Load fresh session data in the background without blocking the UI boot sequence
    unawaited(_refreshSessionFromServer());
  }

/**
 * Refresh Session From Server.
 */
  Future<void> _refreshSessionFromServer() async {
    final storage = _ref.read(secureStorageServiceProvider);

    try {
      final me = await _repo.me();
      final role = me.role;
      final verificationStatus = me.verificationStatus;

      if (kDebugMode) {
        debugPrint(
          '[AuthController] me response '
          'role=${role.apiValue} '
          'verificationStatus=${verificationStatus.apiValue} '
          'registrationStep=${me.registrationStep} '
          'onboardingCompleted=${me.onboardingCompleted}',
        );
      }

      await storage.saveSession(
        userId: me.userId,
        role: role,
        verificationStatus: verificationStatus,
        registrationStep: me.registrationStep,
        onboardingCompleted: me.onboardingCompleted,
      );

      state = state.copyWith(
        role: role,
        registrationStep: me.registrationStep,
        verificationStatus: verificationStatus,
        onboardingCompleted: me.onboardingCompleted,
        isLoggedIn: true,
        isLoading: false,
        isInitialized: true,
        clearError: true,
      );
      _ref.read(selectedRoleProvider.notifier).state = role;
      return;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 || e.response?.statusCode == 404) {
        await logout();
        state = state.copyWith(isInitialized: true, isLoading: false);
        return;
      }
      if (kDebugMode) {
        debugPrint(
          '[AuthController] refreshSession dio error '
          'status=${e.response?.statusCode} '
          'message=${_extractError(e)}',
        );
      }
    } catch (_) {
      // Keep the locally restored session if the refresh fails.
      if (kDebugMode) {
        debugPrint('[AuthController] refreshSession failed - keeping local session');
      }
    }
  }

/**
 * Refresh Session.
 */
  Future<void> refreshSession() async {
    if (kDebugMode) {
      debugPrint('[AuthController] refreshSession started');
    }
    state = state.copyWith(isLoading: true, clearError: true);
    await _refreshSessionFromServer();
    state = state.copyWith(isLoading: false, isInitialized: true);
    if (kDebugMode) {
      debugPrint(
        '[AuthController] refreshSession finished '
        'verificationStatus=${state.verificationStatus.apiValue} '
        'registrationStep=${state.registrationStep} '
        'onboardingCompleted=${state.onboardingCompleted}',
      );
    }
  }

/**
 * Complete Onboarding.
 */
  Future<void> completeOnboarding() async {
    final storage = _ref.read(secureStorageServiceProvider);
    final updated = state.copyWith(
      onboardingCompleted: true,
      registrationStep: 0,
      verificationStatus: VerificationStatus.pending,
      clearError: true,
    );

    state = updated;
    await storage.saveSession(
      role: updated.role,
      verificationStatus: updated.verificationStatus,
      registrationStep: updated.registrationStep,
      onboardingCompleted: true,
    );
  }

/**
 * Update Registration Step.
 */
  Future<void> updateRegistrationStep(int step) async {
    final storage = _ref.read(secureStorageServiceProvider);
    state = state.copyWith(
      registrationStep: step,
      clearError: true,
    );
    await storage.saveSession(
      role: state.role,
      verificationStatus: state.verificationStatus,
      registrationStep: step,
      onboardingCompleted: state.onboardingCompleted,
    );
  }

/**
 * Update Verification Status.
 */
  Future<void> updateVerificationStatus(VerificationStatus status) async {
    final storage = _ref.read(secureStorageServiceProvider);
    state = state.copyWith(
      verificationStatus: status,
      clearError: true,
    );
    await storage.saveSession(
      role: state.role,
      verificationStatus: status,
      registrationStep: state.registrationStep,
      onboardingCompleted: state.onboardingCompleted,
    );
  }

/**
 * Logout.
 */
  Future<void> logout() async {
    await _repo.logout();
    final storage = _ref.read(secureStorageServiceProvider);
    await storage.clearPendingRole();
    _ref.read(selectedRoleProvider.notifier).state = null;
    state = const AuthState(isInitialized: true);
  }

/**
 * Extract Error.
 */
  String _extractError(DioException e) {
    final data = e.response?.data;

    if (data is Map<String, dynamic>) {
      final details = data['details'];
      if (details is Map<String, dynamic> && details.isNotEmpty) {
        final firstDetail = details.values.first;
        if (firstDetail != null && firstDetail.toString().trim().isNotEmpty) {
          return firstDetail.toString();
        }
      }

      return (data['message'] ?? data['error'] ?? 'Something went wrong')
          .toString();
    }

    return e.message ?? 'Something went wrong';
  }

  UserRole? _decodeRoleFromToken(String token) {
    try {
      final payload = JwtParser.parse(token);
      return UserRole.fromApiValue(payload['role']);
    } catch (_) {
      return null;
    }
  }
}
