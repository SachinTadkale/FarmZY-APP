/**
 * Module: My Crops Repository
 * Purpose: Implements the My Crops Repository module for the FarmZy mobile app.
 * Note: Documentation-only change; behavior remains unchanged.
 */
import 'package:dio/dio.dart';
import 'package:farmzy/core/network/api_client.dart';
import 'package:farmzy/features/my_crops/data/models/crop_product.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

final myCropsRepositoryProvider = Provider<MyCropsRepository>((ref) {
  final api = ref.read(apiClientProvider);
  return MyCropsRepository(api);
});

/**
 * My Crops Repository.
 */
class MyCropsRepository {
  final ApiClient _api;

  MyCropsRepository(this._api);

  Future<List<CropProduct>> getMyProducts() async {
    final response = await _api.get('products/get-product');
    final data = response.data['data'] as List<dynamic>? ?? <dynamic>[];

    return data
        .whereType<Map<String, dynamic>>()
        .map(CropProduct.fromJson)
        .toList();
  }

/**
 * Create Product.
 */
  Future<String> createProduct({
    required String name,
    required String category,
    required String unit,
    XFile? image,
  }) async {
    final formData = FormData.fromMap({
      'productName': name,
      'category': category,
      'unit': unit,
      if (image != null)
        'productImage': await MultipartFile.fromFile(
          image.path,
          filename: image.name,
        ),
    });

    final response = await _api.postForm('products/add-product', data: formData);
    return (response.data['message'] ?? 'Product created successfully')
        .toString();
  }

/**
 * Update Product.
 */
  Future<String> updateProduct({
    required String productId,
    required String name,
    required String category,
    required String unit,
    XFile? image,
  }) async {
    final formData = FormData.fromMap({
      'productName': name,
      'category': category,
      'unit': unit,
      if (image != null)
        'productImage': await MultipartFile.fromFile(
          image.path,
          filename: image.name,
        ),
    });

    final response = await _api.patchForm(
      'products/udpate-product/$productId',
      data: formData,
    );

    return (response.data['message'] ?? 'Product updated successfully')
        .toString();
  }

/**
 * Delete Product.
 */
  Future<String> deleteProduct(String productId) async {
    final response = await _api.delete('products/delete-product/$productId');
    return (response.data['message'] ?? 'Product deleted successfully')
        .toString();
  }

  Future<List<Map<String, dynamic>>> getCategoriesWithUnits() async {
    final response = await _api.get('products/meta/categories-units');
    return List<Map<String, dynamic>>.from(response.data['data']);
  }

  Future<List<String>> getAllUnits() async {
    final response = await _api.get('products/meta/units');
    return List<String>.from(response.data['data']);
  }
}
