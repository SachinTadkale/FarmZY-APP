class LoginResponse {
  final String token;
  final String message;
  final int registrationStep;
  final bool onboardingCompleted;
  final String verificationStatus;

  LoginResponse({
    required this.token,
    required this.message,
    required this.registrationStep,
    required this.onboardingCompleted,
    required this.verificationStatus,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] ?? '',
      message: json['message'] ?? '',

      registrationStep: json['registrationStep'] ?? 0,
      onboardingCompleted: json['onboardingCompleted'] ?? false,
      verificationStatus: json['verificationStatus'] ?? 'PENDING',
    );
  }
}