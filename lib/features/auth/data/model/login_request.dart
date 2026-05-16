/**
 * Module: Login Request
 * Purpose: Implements the Login Request module for the FarmZy mobile app.
 * Note: Documentation-only change; behavior remains unchanged.
 */
import 'package:farmzy/shared/enums/user_role.dart';

/**
 * Login Request.
 */
class LoginRequest {
  final String email;
  final String password;
  final UserRole? role;

  LoginRequest({
    required this.email,
    required this.password,
    this.role,
  });

/**
 * To Json.
 */
  Map<String, dynamic> toJson() {
    return {
      "email": email,
      "password": password,
      if (role != null) "role": role!.apiValue,
    };
  }
}
