import 'package:farmzy/shared/models/pagination_model.dart';

class MarketplaceListing {
  final String id;
  final ListingProduct product;
  final ListingSeller seller;
  final double price;
  final double quantity;
  final double? minOrder;
  final String listingType;
  final String status;
  final ListingLocation location;
  final double? distanceKm;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const MarketplaceListing({
    required this.id,
    required this.product,
    required this.seller,
    required this.price,
    required this.quantity,
    required this.minOrder,
    required this.listingType,
    required this.status,
    required this.location,
    required this.distanceKm,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MarketplaceListing.fromJson(Map<String, dynamic> json) {
    return MarketplaceListing(
      id: (json['id'] ?? '').toString(),
      product: ListingProduct.fromJson(
        json['product'] as Map<String, dynamic>? ?? const {},
      ),
      seller: ListingSeller.fromJson(
        json['seller'] as Map<String, dynamic>? ?? const {},
      ),
      price: (json['price'] as num? ?? 0).toDouble(),
      quantity: (json['quantity'] as num? ?? 0).toDouble(),
      minOrder: (json['minOrder'] as num?)?.toDouble(),
      listingType: (json['listingType'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      location: ListingLocation.fromJson(
        json['location'] as Map<String, dynamic>? ?? const {},
      ),
      distanceKm: (json['distanceKm'] as num?)?.toDouble(),
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()),
      updatedAt: DateTime.tryParse((json['updatedAt'] ?? '').toString()),
    );
  }
}

class ListingProduct {
  final String id;
  final String name;
  final String category;
  final String unit;
  final String? imageUrl;

  const ListingProduct({
    required this.id,
    required this.name,
    required this.category,
    required this.unit,
    required this.imageUrl,
  });

  factory ListingProduct.fromJson(Map<String, dynamic> json) {
    return ListingProduct(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
      unit: (json['unit'] ?? '').toString(),
      imageUrl: json['image']?.toString(),
    );
  }
}

class ListingSeller {
  final String id;
  final String name;

  const ListingSeller({
    required this.id,
    required this.name,
  });

  factory ListingSeller.fromJson(Map<String, dynamic> json) {
    return ListingSeller(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
    );
  }
}

class ListingLocation {
  final String address;
  final String? state;
  final String? district;
  final String? village;
  final String? pincode;

  const ListingLocation({
    required this.address,
    required this.state,
    required this.district,
    required this.village,
    required this.pincode,
  });

  factory ListingLocation.fromJson(Map<String, dynamic> json) {
    return ListingLocation(
      address: (json['address'] ?? '').toString(),
      state: json['state']?.toString(),
      district: json['district']?.toString(),
      village: json['village']?.toString(),
      pincode: json['pincode']?.toString(),
    );
  }
}

class MarketplaceListingResult {
  final String mode;
  final List<MarketplaceListing> listings;
  final PaginationModel pagination;

  const MarketplaceListingResult({
    required this.mode,
    required this.listings,
    required this.pagination,
  });

  factory MarketplaceListingResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as List<dynamic>? ?? <dynamic>[];

    return MarketplaceListingResult(
      mode: (json['mode'] ?? 'normal').toString(),
      listings: data
          .whereType<Map<String, dynamic>>()
          .map(MarketplaceListing.fromJson)
          .toList(),
      pagination: PaginationModel.fromJson(
        json['pagination'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }
}
