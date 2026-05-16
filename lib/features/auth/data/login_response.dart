/**
 * Module: Login Response
 * Purpose: Implements the Login Response module for the FarmZy mobile app.
 * Note: Documentation-only change; behavior remains unchanged.
 */
/**
 * Login Response.
 */
class LoginResponse {
  final String token;
  final String message;
  final int registrationStep;
  final bool onboardingCompleted;
  final String verificationStatus;
  final String role;

  LoginResponse({
    required this.token,
    required this.message,
    required this.registrationStep,
    required this.onboardingCompleted,
    required this.verificationStatus,
    required this.role,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final nestedData = data is Map<String, dynamic> ? data : <String, dynamic>{};
    final user = nestedData['user'];
    final nestedUser = user is Map<String, dynamic> ? user : <String, dynamic>{};

    return LoginResponse(
      token: (json['token'] ??
              json['accessToken'] ??
              nestedData['token'] ??
              nestedUser['token'] ??
              '')
          .toString(),
      message: (json['message'] ?? nestedData['message'] ?? '').toString(),
      registrationStep: int.tryParse(
            (json['registrationStep'] ??
                    nestedData['registrationStep'] ??
                    nestedUser['registrationStep'] ??
                    '0')
                .toString(),
          ) ??
          0,
      onboardingCompleted:
          (json['onboardingCompleted'] ??
                  nestedData['onboardingCompleted'] ??
                  nestedUser['onboardingCompleted'] ??
                  false)
              .toString() ==
          'true',
      verificationStatus: (json['verificationStatus'] ??
              nestedData['verificationStatus'] ??
              nestedUser['verificationStatus'] ??
              'PENDING')
          .toString(),
      role: (json['role'] ?? nestedData['role'] ?? nestedUser['role'] ?? 'FARMER')
          .toString(),
    );
  }
}
