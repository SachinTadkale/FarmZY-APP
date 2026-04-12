import 'package:dio/dio.dart';
import 'package:farmzy/features/marketplace/data/models/marketplace_listing.dart';
import 'package:farmzy/features/marketplace/data/marketplace_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class MarketplaceFilterState {
  final String search;
  final String category;
  final double? minPrice;
  final double? maxPrice;
  final String sortBy;
  final String order;

  const MarketplaceFilterState({
    this.search = '',
    this.category = '',
    this.minPrice,
    this.maxPrice,
    this.sortBy = 'createdAt',
    this.order = 'desc',
  });

  MarketplaceFilterState copyWith({
    String? search,
    String? category,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    String? order,
    bool clearMinPrice = false,
    bool clearMaxPrice = false,
  }) {
    return MarketplaceFilterState(
      search: search ?? this.search,
      category: category ?? this.category,
      minPrice: clearMinPrice ? null : minPrice ?? this.minPrice,
      maxPrice: clearMaxPrice ? null : maxPrice ?? this.maxPrice,
      sortBy: sortBy ?? this.sortBy,
      order: order ?? this.order,
    );
  }
}

class MyListingFilterState {
  final String status;
  final String sortBy;
  final String order;

  const MyListingFilterState({
    this.status = '',
    this.sortBy = 'createdAt',
    this.order = 'desc',
  });

  MyListingFilterState copyWith({
    String? status,
    String? sortBy,
    String? order,
  }) {
    return MyListingFilterState(
      status: status ?? this.status,
      sortBy: sortBy ?? this.sortBy,
      order: order ?? this.order,
    );
  }
}

final marketplaceRefreshProvider = StateProvider<int>((ref) => 0);
final marketplaceFilterProvider =
    StateProvider<MarketplaceFilterState>((ref) => const MarketplaceFilterState());
final myListingFilterProvider =
    StateProvider<MyListingFilterState>((ref) => const MyListingFilterState());

final marketplaceListingsProvider =
    FutureProvider<MarketplaceListingResult>((ref) async {
      ref.watch(marketplaceRefreshProvider);
      final filters = ref.watch(marketplaceFilterProvider);
      return ref.read(marketplaceRepositoryProvider).getMarketplaceListings(
            search: filters.search,
            category: filters.category,
            minPrice: filters.minPrice,
            maxPrice: filters.maxPrice,
            sortBy: filters.sortBy,
            order: filters.order,
          );
    });

final myListingsProvider = FutureProvider<MarketplaceListingResult>((ref) async {
  ref.watch(marketplaceRefreshProvider);
  final filters = ref.watch(myListingFilterProvider);
  return ref.read(marketplaceRepositoryProvider).getMyListings(
        status: filters.status,
        sortBy: filters.sortBy,
        order: filters.order,
      );
});

final listingMutationControllerProvider =
    StateNotifierProvider<ListingMutationController, AsyncValue<String?>>((ref) {
      return ListingMutationController(ref);
    });

class ListingMutationController extends StateNotifier<AsyncValue<String?>> {
  final Ref _ref;

  ListingMutationController(this._ref) : super(const AsyncValue.data(null));

  Future<void> createListing({
    required String productId,
    required double price,
    required double quantity,
    required double minOrder,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final message =
          await _ref.read(marketplaceRepositoryProvider).createListing(
                productId: productId,
                price: price,
                quantity: quantity,
                minOrder: minOrder,
              );
      _refresh();
      return message;
    });
  }

  Future<void> updateListing({
    required String listingId,
    required double price,
    required double quantity,
    required double minOrder,
    required String status,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final message =
          await _ref.read(marketplaceRepositoryProvider).updateListing(
                listingId: listingId,
                price: price,
                quantity: quantity,
                minOrder: minOrder,
                status: status,
              );
      _refresh();
      return message;
    });
  }

  Future<void> deleteListing(String listingId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final message =
          await _ref.read(marketplaceRepositoryProvider).deleteListing(
                listingId,
              );
      _refresh();
      return message;
    });
  }

  String? readableError() {
    return state.whenOrNull(
      error: (error, _) {
        if (error is DioException) {
          final data = error.response?.data;
          if (data is Map<String, dynamic> && data['message'] != null) {
            return data['message'].toString();
          }
        }
        return error.toString();
      },
    );
  }

  void clear() {
    state = const AsyncValue.data(null);
  }

  void _refresh() {
    _ref.read(marketplaceRefreshProvider.notifier).state++;
  }
}
