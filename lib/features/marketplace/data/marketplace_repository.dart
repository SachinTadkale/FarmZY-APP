import 'package:farmzy/core/network/api_client.dart';
import 'package:farmzy/features/marketplace/data/models/marketplace_listing.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final marketplaceRepositoryProvider = Provider<MarketplaceRepository>((ref) {
  final api = ref.read(apiClientProvider);
  return MarketplaceRepository(api);
});

class MarketplaceRepository {
  final ApiClient _api;

  MarketplaceRepository(this._api);

  Future<MarketplaceListingResult> getMarketplaceListings({
    String? search,
    String? category,
    double? minPrice,
    double? maxPrice,
    String sortBy = 'createdAt',
    String order = 'desc',
  }) async {
    final response = await _api.get(
      'marketplace/listings',
      queryParameters: {
        ...?search != null && search.isNotEmpty ? {'search': search} : null,
        ...?category != null && category.isNotEmpty
            ? {'category': category}
            : null,
        ...?minPrice != null ? {'minPrice': minPrice} : null,
        ...?maxPrice != null ? {'maxPrice': maxPrice} : null,
        'sortBy': sortBy,
        'order': order,
      },
    );

    return MarketplaceListingResult.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<MarketplaceListingResult> getMyListings({
    String? status,
    String sortBy = 'createdAt',
    String order = 'desc',
  }) async {
    final response = await _api.get(
      'marketplace/my-listings',
      queryParameters: {
        ...?status != null && status.isNotEmpty ? {'status': status} : null,
        'sortBy': sortBy,
        'order': order,
      },
    );

    return MarketplaceListingResult.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<String> createListing({
    required String productId,
    required double price,
    required double quantity,
    required double minOrder,
    double latitude = 18.5204,
    double longitude = 73.8567,
  }) async {
    final response = await _api.post(
      'marketplace/listings',
      data: {
        'productId': productId,
        'price': price,
        'quantity': quantity,
        'minOrder': minOrder,
        'latitude': latitude,
        'longitude': longitude,
        'listingType': 'SELL',
      },
    );

    return (response.data['message'] ?? 'Listing created successfully')
        .toString();
  }

  Future<String> updateListing({
    required String listingId,
    required double price,
    required double quantity,
    required double minOrder,
    required String status,
  }) async {
    final response = await _api.patch(
      'marketplace/listings/$listingId',
      data: {
        'price': price,
        'quantity': quantity,
        'minOrder': minOrder,
        'status': status,
      },
    );

    return (response.data['message'] ?? 'Listing updated successfully')
        .toString();
  }

  Future<String> deleteListing(String listingId) async {
    final response = await _api.delete('marketplace/listings/$listingId');
    return (response.data['message'] ?? 'Listing cancelled successfully')
        .toString();
  }
}
