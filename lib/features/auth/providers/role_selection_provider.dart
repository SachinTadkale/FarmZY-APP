/**
 * Module: Role Selection Provider
 * Purpose: Implements the Role Selection Provider module for the FarmZy mobile app.
 * Note: Documentation-only change; behavior remains unchanged.
 */
import 'package:farmzy/shared/enums/user_role.dart';
import 'package:flutter_riverpod/legacy.dart';

final selectedRoleProvider = StateProvider<UserRole?>((ref) => null);
final authInvalidationProvider = StateProvider<int>((ref) => 0);
