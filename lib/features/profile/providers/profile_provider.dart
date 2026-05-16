/**
 * Module: Profile Provider
 * Purpose: Implements the Profile Provider module for the FarmZy mobile app.
 * Note: Documentation-only change; behavior remains unchanged.
 */
import 'package:dio/dio.dart';
import 'package:farmzy/core/network/api_client.dart';
import 'package:farmzy/core/storage/secure_storage_service.dart';
import 'package:farmzy/features/profile/data/models/farmer_profile.dart';
import 'package:farmzy/shared/enums/user_role.dart';
import 'package:farmzy/shared/enums/verification_status.dart';
import 'package:farmzy/shared/utils/jwt_parser.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:image_picker/image_picker.dart';

final profileRefreshProvider = StateProvider<int>((ref) => 0);

final profileProvider = FutureProvider<FarmerProfile>((ref) async {
  ref.watch(profileRefreshProvider);
  final storage = ref.read(secureStorageServiceProvider);
  final api = ref.read(apiClientProvider);

  try {
    final response = await api.get('users/me');
    final data = response.data['data'];
    
    if (data != null) {
      final profile = FarmerProfile.fromJson(data);
      
      // Update local session for offline access / quick load
      await storage.saveSession(
        userId: profile.userId,
        role: UserRole.fromApiValue(profile.role),
        actorType: profile.role, // Assuming same for now
        name: profile.name,
        email: profile.email ?? '',
        verificationStatus: VerificationStatus.fromApiValue(profile.verificationStatus),
      );
      
      return profile;
    }
    throw Exception("Invalid profile data");
  } on DioException catch (e) {
    // If offline, try to load from session
    final session = await storage.getSession();
    if (session['userId'] != null) {
      return FarmerProfile(
        userId: session['userId']!,
        name: session['name'] ?? 'Farmer',
        email: session['email'],
        role: session['role'] ?? 'FARMER',
        verificationStatus: session['verificationStatus']?.toString() ?? 'PENDING',
      );
    }
    rethrow;
  }
});

final profileMutationProvider = StateNotifierProvider<ProfileMutationController, AsyncValue<String?>>((ref) {
  return ProfileMutationController(ref);
});

class ProfileMutationController extends StateNotifier<AsyncValue<String?>> {
  final Ref _ref;
  ProfileMutationController(this._ref) : super(const AsyncValue.data(null));

  Future<void> updateProfileImage(XFile image) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final api = _ref.read(apiClientProvider);
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(image.path, filename: image.name),
      });
      
      final response = await api.postForm('users/me/avatar', data: formData);
      _ref.read(profileRefreshProvider.notifier).state++;
      return response.data['message']?.toString();
    });
  }

  Future<void> updateProfile({String? name, String? location, String? email}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final api = _ref.read(apiClientProvider);
      final response = await api.patch('users/me', data: {
        if (name != null) 'name': name,
        if (location != null) 'location': location,
        if (email != null) 'email': email,
      });
      _ref.read(profileRefreshProvider.notifier).state++;
      return response.data['message']?.toString();
    });
  }
}
