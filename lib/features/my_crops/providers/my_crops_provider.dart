/**
 * Module: My Crops Provider
 * Purpose: Implements the My Crops Provider module for the FarmZy mobile app.
 * Note: Documentation-only change; behavior remains unchanged.
 */
import 'package:farmzy/core/network/app_network_error.dart';
import 'package:farmzy/features/my_crops/data/models/crop_product.dart';
import 'package:farmzy/features/my_crops/data/my_crops_repository.dart';
import 'package:farmzy/features/profile/providers/profile_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:image_picker/image_picker.dart';

final myCropsRefreshProvider = StateProvider<int>((ref) => 0);
final myCropsSearchProvider = StateProvider<String>((ref) => '');

final productMetadataProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return ref.read(myCropsRepositoryProvider).getCategoriesWithUnits();
});

final myCropsProvider = FutureProvider<List<CropProduct>>((ref) async {
  ref.watch(myCropsRefreshProvider);
  final search = ref.watch(myCropsSearchProvider).trim().toLowerCase();
  final crops = await ref.read(myCropsRepositoryProvider).getMyProducts();

  if (search.isEmpty) {
    return crops;
  }

  return crops.where((crop) {
    return crop.name.toLowerCase().contains(search) ||
        crop.category.toLowerCase().contains(search) ||
        crop.unit.toLowerCase().contains(search);
  }).toList();
});

final cropMutationControllerProvider =
    StateNotifierProvider<CropMutationController, AsyncValue<String?>>((ref) {
      return CropMutationController(ref);
    });

/**
 * Crop Mutation Controller.
 */
class CropMutationController extends StateNotifier<AsyncValue<String?>> {
  final Ref _ref;

  CropMutationController(this._ref) : super(const AsyncValue.data(null));

/**
 * Create Crop.
 */
  Future<void> createCrop({
    required String name,
    required String category,
    required String unit,
    XFile? image,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final message = await _ref.read(myCropsRepositoryProvider).createProduct(
            name: name,
            category: category,
            unit: unit,
            image: image,
          );
      _refresh();
      return message;
    });
  }

/**
 * Update Crop.
 */
  Future<void> updateCrop({
    required String productId,
    required String name,
    required String category,
    required String unit,
    XFile? image,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final message = await _ref.read(myCropsRepositoryProvider).updateProduct(
            productId: productId,
            name: name,
            category: category,
            unit: unit,
            image: image,
          );
      _refresh();
      return message;
    });
  }

/**
 * Delete Crop.
 */
  Future<void> deleteCrop(String productId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final message =
          await _ref.read(myCropsRepositoryProvider).deleteProduct(productId);
      _refresh();
      return message;
    });
  }

  String? readableError() {
    return state.whenOrNull(
      error: (error, _) {
        return AppNetworkError.userMessage(error);
      },
    );
  }

/**
 * Clear.
 */
  void clear() {
    state = const AsyncValue.data(null);
  }

/**
 * Refresh.
 */
  void _refresh() {
    _ref.read(myCropsRefreshProvider.notifier).state++;
    _ref.invalidate(profileProvider);
  }
}
