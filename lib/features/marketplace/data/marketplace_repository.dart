/**
 * Module: Marketplace Repository
 * Purpose: Implements the Marketplace Repository module for the FarmZy mobile app.
 * Note: Documentation-only change; behavior remains unchanged.
 */
import 'package:farmzy/core/network/api_client.dart';
import 'package:farmzy/features/marketplace/data/models/marketplace_listing.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final marketplaceRepositoryProvider = Provider<MarketplaceRepository>((ref) {
  final api = ref.read(apiClientProvider);
  return MarketplaceRepository(api);
});

/**
 * Marketplace Repository.
 */
class MarketplaceRepository {
  final ApiClient _api;

  MarketplaceRepository(this._api);

/**
 * Get Marketplace Listings.
 */
  Future<MarketplaceListingResult> getMarketplaceListings({
    String? search,
    String? category,
    double? minPrice,
    double? maxPrice,
    String sortBy = 'createdAt',
    String order = 'desc',
  }) async {
    final response = await _api.get(
      'marketplace/getListings',
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

/**
 * Get Single Listing By Id.
 */
  Future<MarketplaceListing> getListingById(String id) async {
    final response = await _api.get('marketplace/getListingById/$id');
    final data = response.data['data'];
    if (data == null) throw Exception('Listing not found');
    return MarketplaceListing.fromJson(data as Map<String, dynamic>);
  }

/**
 * Get My Listings.
 */
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

/**
 * Create Listing.
 */
  Future<String> createListing({
    required String productId,
    required double price,
    required double quantity,
    required double minOrder,
    double latitude = 18.5204,
    double longitude = 73.8567,
  }) async {
    final response = await _api.post(
      'marketplace/addListing',
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

/**
 * Update Listing.
 */
  Future<String> updateListing({
    required String listingId,
    required double price,
    required double quantity,
    required double minOrder,
    required String status,
  }) async {
    final response = await _api.patch(
      'marketplace/updateListing/$listingId',
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

/**
 * Delete Listing.
 */
  Future<String> deleteListing(String listingId) async {
    final response = await _api.delete(
      'marketplace/deleteListing/$listingId',
    );
    return (response.data['message'] ?? 'Listing cancelled successfully')
        .toString();
  }

  /**
   * Get Available Product Units.
   */
  Future<List<String>> getProductUnits() async {
    final response = await _api.get('products/meta/units');
    final data = response.data['data'] as List<dynamic>;
    return data.map((e) => e.toString()).toList();
  }
}
