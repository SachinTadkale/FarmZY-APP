/**
 * Module: Reset Password Request
 * Purpose: Implements the Reset Password Request module for the FarmZy mobile app.
 * Note: Documentation-only change; behavior remains unchanged.
 */
/**
 * Reset Password Request.
 */
class ResetPasswordRequest {
  final String email;
  final String otp;
  final String newPassword;
  final String confirmPassword;

  ResetPasswordRequest({
    required this.email,
    required this.otp,
    required this.newPassword,
    required this.confirmPassword,
  });

/**
 * To Json.
 */
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'otp': otp,
      'newPassword': newPassword,
      'confirmPassword': confirmPassword,
    };
  }
}
