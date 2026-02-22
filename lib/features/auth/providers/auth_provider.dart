import 'package:flutter_riverpod/legacy.dart';

final authProvider = StateProvider<bool>((ref) {
  // later replace with token check
  return false; // false = NOT logged in
});

/*
Handles

Login

Logout

Token

Session

Current user

Auth status */