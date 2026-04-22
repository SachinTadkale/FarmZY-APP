class AuthState {
  final String? token;
  final int registrationStep;
  final String verificationStatus;
  final bool onboardingCompleted;
  final bool isLoggedIn;
  final bool isLoading;
  final String? error;
  final bool isInitialized;

  AuthState({
    this.token,
    this.registrationStep = 0,
    this.verificationStatus = "PENDING",
    this.onboardingCompleted = false,
    this.isLoggedIn = false,
    this.isLoading = false,
    this.isInitialized = false,
    this.error,
  });

  AuthState copyWith({
    String? token,
    int? registrationStep,
    String? verificationStatus,
    bool? onboardingCompleted,
    bool? isLoggedIn,
    bool? isLoading,
    bool? isInitialized,
    String? error,
  }) {
    return AuthState(
      token: token ?? this.token,
      registrationStep: registrationStep ?? this.registrationStep,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isLoading: isLoading ?? this.isLoading,
      isInitialized: isInitialized ?? this.isInitialized,
      error: error,
    );
  }
}
