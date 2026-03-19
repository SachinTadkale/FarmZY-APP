import 'package:farmzy/core/storage/secure_storage_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final authProvider = StateProvider<bool>((ref) {
  return false; // false = NOT logged in
});

final authBootstrapProvider = FutureProvider<void>((ref) async {
  final storage = ref.read(secureStorageServiceProvider);
  final token = await storage.getToken();

  ref.read(authProvider.notifier).state = token != null && token.isNotEmpty;
});

/*
Handles

Login

Logout

Token

Session

Current user

Auth status */
