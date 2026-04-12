import 'package:dio/dio.dart';
import 'package:farmzy/core/network/api_client.dart';
import 'package:farmzy/features/my_crops/data/models/crop_product.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

final myCropsRepositoryProvider = Provider<MyCropsRepository>((ref) {
  final api = ref.read(apiClientProvider);
  return MyCropsRepository(api);
});

class MyCropsRepository {
  final ApiClient _api;

  MyCropsRepository(this._api);

  Future<List<CropProduct>> getMyProducts() async {
    final response = await _api.get('product/get-product');
    final data = response.data['data'] as List<dynamic>? ?? <dynamic>[];

    return data
        .whereType<Map<String, dynamic>>()
        .map(CropProduct.fromJson)
        .toList();
  }

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

    final response = await _api.postForm('product/add-product', data: formData);
    return (response.data['message'] ?? 'Product created successfully')
        .toString();
  }

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
      'product/udpate-product/$productId',
      data: formData,
    );

    return (response.data['message'] ?? 'Product updated successfully')
        .toString();
  }

  Future<String> deleteProduct(String productId) async {
    final response = await _api.delete('product/delete-product/$productId');
    return (response.data['message'] ?? 'Product deleted successfully')
        .toString();
  }
}
