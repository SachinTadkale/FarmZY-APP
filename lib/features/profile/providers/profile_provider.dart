import 'package:dio/dio.dart';
import 'package:farmzy/core/network/api_client.dart';
import 'package:farmzy/core/storage/secure_storage_service.dart';
import 'package:farmzy/features/profile/data/models/farmer_profile.dart';
import 'package:farmzy/shared/utils/jwt_parser.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final profileProvider = FutureProvider<FarmerProfile>((ref) async {
  final storage = ref.read(secureStorageServiceProvider);
  final api = ref.read(apiClientProvider);
  final session = await storage.getSession();
  final token = await storage.getToken();
  final payload = token != null ? JwtParser.parse(token) : <String, String?>{};

  String userId = session['userId'] ?? payload['userId'] ?? 'Unknown';
  String role = session['role'] ?? payload['role'] ?? 'USER';
  String actorType = session['actorType'] ?? payload['actorType'] ?? 'USER';
  String verificationStatus = session['verificationStatus'] ?? 'VERIFIED';

  try {
    final response = await api.get('user/dashboard');
    final user = response.data['user'];
    if (user is Map<String, dynamic>) {
      userId = (user['userId'] ?? userId).toString();
      role = (user['role'] ?? role).toString();
      actorType = (user['actorType'] ?? actorType).toString();
      verificationStatus = 'VERIFIED';
      await storage.saveSession(
        userId: userId,
        role: role,
        actorType: actorType,
        verificationStatus: verificationStatus,
      );
    }
  } on DioException {
    // Keep the best-known local session state when dashboard access is unavailable.
  }

  return FarmerProfile(
    userId: userId,
    name: session['name']?.trim().isNotEmpty == true
        ? session['name']!.trim()
        : 'FarmZY Farmer',
    email: session['email']?.trim().isNotEmpty == true
        ? session['email']!.trim()
        : 'Email unavailable',
    role: role,
    actorType: actorType,
    verificationStatus: verificationStatus,
  );
});
