/**
 * Module: Auth Session
 * Purpose: Implements the Auth Session module for the FarmZy mobile app.
 * Note: Documentation-only change; behavior remains unchanged.
 */
import 'package:farmzy/shared/enums/user_role.dart';
import 'package:farmzy/shared/enums/verification_status.dart';

/**
 * Auth Session.
 */
class AuthSession {
  final String? userId;
  final UserRole role;
  final int registrationStep;
  final VerificationStatus verificationStatus;
  final bool onboardingCompleted;

  const AuthSession({
    required this.userId,
    required this.role,
    required this.registrationStep,
    required this.verificationStatus,
    required this.onboardingCompleted,
  });

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final nestedData = data is Map<String, dynamic> ? data : <String, dynamic>{};
    final user = nestedData['user'];
    final topLevelUser = json['user'];
    final nestedUser = user is Map<String, dynamic>
        ? user
        : topLevelUser is Map<String, dynamic>
            ? topLevelUser
            : <String, dynamic>{};

    return AuthSession(
      userId: (json['userId'] ?? nestedData['userId'] ?? nestedUser['userId'])
          ?.toString(),
      role: UserRole.fromApiValue(
        (json['role'] ?? nestedData['role'] ?? nestedUser['role'])?.toString(),
      ),
      registrationStep: int.tryParse(
            (json['registrationStep'] ??
                    nestedData['registrationStep'] ??
                    nestedUser['registrationStep'] ??
                    '0')
                .toString(),
          ) ??
          0,
      verificationStatus: VerificationStatus.fromApiValue(
        (json['verificationStatus'] ??
                nestedData['verificationStatus'] ??
                nestedUser['verificationStatus'])
            ?.toString(),
      ),
      onboardingCompleted:
          (json['onboardingCompleted'] ??
                  nestedData['onboardingCompleted'] ??
                  nestedUser['onboardingCompleted'] ??
                  false)
              .toString() ==
          'true',
    );
  }
}
