import 'package:dio/dio.dart';
import 'package:farmzy/features/auth/data/auth_repository.dart';
import 'package:farmzy/features/auth/data/model/login_request.dart';
import 'package:farmzy/features/auth/data/model/otp_request.dart';
import 'package:farmzy/features/auth/data/model/reset_password_request.dart';
import 'package:farmzy/features/auth/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

enum AuthAction {
  otpSent,
  passwordResetOtpSent,
  passwordResetCompleted,
  loggedIn,
  loggedOut,
}

// Provider
final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<AuthAction?>>((ref) {
      final repo = ref.read(authRepositoryProvider);
      return AuthController(ref, repo);
    });

// Controller
class AuthController extends StateNotifier<AsyncValue<AuthAction?>> {
  final Ref _ref;
  final AuthRepository _repo;

  AuthController(this._ref, this._repo) : super(const AsyncData(null));

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();

    try {
      await _repo.login(LoginRequest(email: email, password: password));

      _ref.read(authProvider.notifier).state = true;
      state = const AsyncData(AuthAction.loggedIn);
    } on DioException catch (e, stackTrace) {
      _setErrorState(e, stackTrace);
    } catch (e, stackTrace) {
      _ref.read(authProvider.notifier).state = false;
      state = AsyncError(e, stackTrace);
    }
  }

  Future<void> requestOtp(String email) async {
    state = const AsyncLoading();

    try {
      await _repo.requestOtp(OtpRequest(email: email));
      _ref.read(authProvider.notifier).state = false;
      state = const AsyncData(AuthAction.otpSent);
    } on DioException catch (e, stackTrace) {
      _setErrorState(e, stackTrace);
    } catch (e, stackTrace) {
      _ref.read(authProvider.notifier).state = false;
      state = AsyncError(e, stackTrace);
    }
  }

  Future<void> loginWithOtp(String email, String otp) async {
    state = const AsyncLoading();

    try {
      await _repo.loginWithOtp(OtpRequest(email: email, otp: otp));
      _ref.read(authProvider.notifier).state = true;
      state = const AsyncData(AuthAction.loggedIn);
    } on DioException catch (e, stackTrace) {
      _setErrorState(e, stackTrace);
    } catch (e, stackTrace) {
      _ref.read(authProvider.notifier).state = false;
      state = AsyncError(e, stackTrace);
    }
  }

  Future<void> forgotPassword(String email) async {
    state = const AsyncLoading();

    try {
      await _repo.forgotPassword(OtpRequest(email: email));
      _ref.read(authProvider.notifier).state = false;
      state = const AsyncData(AuthAction.passwordResetOtpSent);
    } on DioException catch (e, stackTrace) {
      _setErrorState(e, stackTrace);
    } catch (e, stackTrace) {
      _ref.read(authProvider.notifier).state = false;
      state = AsyncError(e, stackTrace);
    }
  }

  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
    required String confirmPassword,
  }) async {
    state = const AsyncLoading();

    try {
      await _repo.resetPassword(
        ResetPasswordRequest(
          email: email,
          otp: otp,
          newPassword: newPassword,
          confirmPassword: confirmPassword,
        ),
      );
      _ref.read(authProvider.notifier).state = false;
      state = const AsyncData(AuthAction.passwordResetCompleted);
    } on DioException catch (e, stackTrace) {
      _setErrorState(e, stackTrace);
    } catch (e, stackTrace) {
      _ref.read(authProvider.notifier).state = false;
      state = AsyncError(e, stackTrace);
    }
  }

  Future<void> logout() async {
    try {
      await _repo.logout();
    } finally {
      _ref.read(authProvider.notifier).state = false;
      state = const AsyncData(AuthAction.loggedOut);
    }
  }

  void _setErrorState(DioException e, StackTrace stackTrace) {
    final responseData = e.response?.data;
    final message =
        responseData is Map<String, dynamic>
            ? ((responseData['message'] ??
                        responseData['error'] ??
                        'Authentication failed.')
                    .toString())
            : (e.message ?? 'Authentication failed.');
    _ref.read(authProvider.notifier).state = false;
    state = AsyncError(Exception(message), stackTrace);
  }
}
