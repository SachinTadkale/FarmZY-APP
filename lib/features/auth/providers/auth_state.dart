/**
 * Module: Auth State
 * Purpose: Implements the Auth State module for the FarmZy mobile app.
 * Note: Documentation-only change; behavior remains unchanged.
 */
import 'package:farmzy/shared/enums/user_role.dart';
import 'package:farmzy/shared/enums/verification_status.dart';

/**
 * Auth State.
 */
class AuthState {
  final String? token;
  final UserRole role;
  final int registrationStep;
  final VerificationStatus verificationStatus;
  final bool onboardingCompleted;
  final bool isLoggedIn;
  final bool isLoading;
  final String? error;
  final bool isInitialized;

  const AuthState({
    this.token,
    this.role = UserRole.farmer,
    this.registrationStep = 0,
    this.verificationStatus = VerificationStatus.pending,
    this.onboardingCompleted = false,
    this.isLoggedIn = false,
    this.isLoading = false,
    this.isInitialized = false,
    this.error,
  });

  bool get hasToken => token != null && token!.isNotEmpty;
  bool get requiresOnboarding => hasToken && !onboardingCompleted;
  bool get requiresVerification =>
      hasToken &&
      onboardingCompleted &&
      verificationStatus != VerificationStatus.approved;

  AuthState copyWith({
    String? token,
    bool clearToken = false,
    UserRole? role,
    int? registrationStep,
    VerificationStatus? verificationStatus,
    bool? onboardingCompleted,
    bool? isLoggedIn,
    bool? isLoading,
    bool? isInitialized,
    String? error,
    bool clearError = false,
  }) {
    return AuthState(
      token: clearToken ? null : (token ?? this.token),
      role: role ?? this.role,
      registrationStep: registrationStep ?? this.registrationStep,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isLoading: isLoading ?? this.isLoading,
      isInitialized: isInitialized ?? this.isInitialized,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
