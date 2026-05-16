/**
 * Module: Register Request
 * Purpose: Implements the Register Request module for the FarmZy mobile app.
 * Note: Documentation-only change; behavior remains unchanged.
 */
import 'package:farmzy/shared/enums/user_role.dart';

/**
 * Register Request.
 */
class RegisterRequest {
  final String name;
  final String email;
  final String phoneNo;
  final String address;
  final String gender;
  final String password;
  final UserRole role;

  RegisterRequest({
    required this.name,
    required this.email,
    required this.phoneNo,
    required this.address,
    required this.gender,
    required this.password,
    required this.role,
  });

/**
 * To Json.
 */
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone_no': phoneNo,
      'address': address,
      'gender': gender,
      'password': password,
      'role': role.apiValue,
    };
  }
}
