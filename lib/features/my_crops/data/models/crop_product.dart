class CropProduct {
  final String id;
  final String name;
  final String category;
  final String unit;
  final String? imageUrl;

  const CropProduct({
    required this.id,
    required this.name,
    required this.category,
    required this.unit,
    this.imageUrl,
  });

  factory CropProduct.fromJson(Map<String, dynamic> json) {
    return CropProduct(
      id: (json['productId'] ?? json['id'] ?? '').toString(),
      name: (json['productName'] ?? json['name'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
      unit: (json['unit'] ?? '').toString(),
      imageUrl: json['productImage']?.toString(),
    );
  }
}
