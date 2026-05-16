/**
 * Module: Otp Request
 * Purpose: Implements the Otp Request module for the FarmZy mobile app.
 * Note: Documentation-only change; behavior remains unchanged.
 */
import 'package:farmzy/shared/enums/user_role.dart';

/**
 * Otp Request.
 */
class OtpRequest {
  final String email;
  final String? otp;
  final UserRole? role;

  OtpRequest({required this.email, this.role, this.otp});

/**
 * To Json.
 */
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      if (role != null) 'role': role!.apiValue,
      if (otp != null) 'otp': otp,
    };
  }
}
