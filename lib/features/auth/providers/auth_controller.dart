import 'package:dio/dio.dart';
import 'package:farmzy/core/storage/secure_storage_service.dart';
import 'package:farmzy/features/auth/data/auth_repository.dart';
import 'package:farmzy/features/auth/data/model/login_request.dart';
import 'package:farmzy/features/auth/data/model/otp_request.dart';
import 'package:farmzy/features/auth/data/model/reset_password_request.dart';
import 'package:farmzy/features/auth/providers/auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

// Provider
final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) {
    final repo = ref.read(authRepositoryProvider);
    return AuthController(ref, repo);
  },
);

// Controller
class AuthController extends StateNotifier<AuthState> {
  final Ref _ref;
  final AuthRepository _repo;
  AuthController(this._ref, this._repo) : super(AuthState());

  /* -------------------------------------------------------------------------- */
  /*                                   LOGIN                                    */
  /* -------------------------------------------------------------------------- */

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final res = await _repo.login(
        LoginRequest(email: email, password: password),
      );

      state = state.copyWith(
        token: res.token,
        registrationStep: res.registrationStep,
        verificationStatus: res.verificationStatus,
        onboardingCompleted: res.onboardingCompleted,
        isLoggedIn: true,
        isLoading: false,
      );
    } on DioException catch (e) {
      state = state.copyWith(isLoading: false, error: _extractError(e));
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /* -------------------------------------------------------------------------- */
  /*                               LOGIN WITH OTP                               */
  /* -------------------------------------------------------------------------- */

  Future<void> loginWithOtp(String email, String otp) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final res = await _repo.loginWithOtp(OtpRequest(email: email, otp: otp));

      state = state.copyWith(
        token: res.token,
        registrationStep: res.registrationStep,
        verificationStatus: res.verificationStatus,
        onboardingCompleted: res.onboardingCompleted,
        isLoggedIn: true,
        isLoading: false,
      );
    } on DioException catch (e) {
      state = state.copyWith(isLoading: false, error: _extractError(e));
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /* -------------------------------------------------------------------------- */
  /*                                  REQUEST OTP                               */
  /* -------------------------------------------------------------------------- */

  Future<void> requestOtp(String email) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _repo.requestOtp(OtpRequest(email: email));

      state = state.copyWith(isLoading: false);
    } on DioException catch (e) {
      state = state.copyWith(isLoading: false, error: _extractError(e));
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /* -------------------------------------------------------------------------- */
  /*                              FORGOT PASSWORD                               */
  /* -------------------------------------------------------------------------- */

  Future<void> forgotPassword(String email) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _repo.forgotPassword(OtpRequest(email: email));

      state = state.copyWith(isLoading: false);
    } on DioException catch (e) {
      state = state.copyWith(isLoading: false, error: _extractError(e));
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /* -------------------------------------------------------------------------- */
  /*                              RESET PASSWORD                                */
  /* -------------------------------------------------------------------------- */

  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
    required String confirmPassword,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _repo.resetPassword(
        ResetPasswordRequest(
          email: email,
          otp: otp,
          newPassword: newPassword,
          confirmPassword: confirmPassword,
        ),
      );

      state = state.copyWith(isLoading: false);
    } on DioException catch (e) {
      state = state.copyWith(isLoading: false, error: _extractError(e));
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /* -------------------------------------------------------------------------- */
  /*                                   LOGOUT                                   */
  /* -------------------------------------------------------------------------- */

  Future<void> logout() async {
    await _repo.logout();

    state = AuthState(); // reset everything
  }

  /* -------------------------------------------------------------------------- */
  /*                               ERROR HANDLER                                */
  /* -------------------------------------------------------------------------- */

  String _extractError(DioException e) {
    final data = e.response?.data;

    if (data is Map<String, dynamic>) {
      return (data['message'] ?? data['error'] ?? 'Something went wrong')
          .toString();
    }

    return e.message ?? 'Something went wrong';
  }

  void updateOnboardingCompleted() {
    state = state.copyWith(
      onboardingCompleted: true,
      registrationStep: 4, // final step
    );
  }

  Future<void> restoreSession() async {
    final storage = _ref.read(secureStorageServiceProvider);
    final session = await storage.getSession();

    state = state.copyWith(
      token: session['token'],
      registrationStep: session['registrationStep'] ?? 0,
      onboardingCompleted: session['onboardingCompleted'] ?? false,
      verificationStatus: session['verificationStatus'] ?? 'PENDING',
      isLoggedIn: true,
      isInitialized: true,
    );
  }
}
