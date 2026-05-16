/**
 * Module: Crop Product
 * Purpose: Implements the Crop Product module for the FarmZy mobile app.
 * Note: Documentation-only change; behavior remains unchanged.
 */
import 'package:farmzy/shared/models/translation_model.dart';

/**
 * Crop Product.
 */
class CropProduct {
  final String id;
  final String name;
  final String category;
  final String unit;
  final String? imageUrl;
  final EntityTranslations translations;
  final bool isListed;

  const CropProduct({
    required this.id,
    required this.name,
    required this.category,
    required this.unit,
    required this.translations,
    this.imageUrl,
    this.isListed = false,
  });

  factory CropProduct.fromJson(Map<String, dynamic> json) {
    return CropProduct(
      id: (json['productId'] ?? json['id'] ?? '').toString(),
      name: (json['productName'] ?? json['name'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
      unit: (json['unit'] ?? '').toString(),
      imageUrl: json['productImage']?.toString(),
      isListed: json['isListed'] == true,
      translations: EntityTranslations.fromJson(
        json['translations'] as Map<String, dynamic>?,
      ),
    );
  }
}
