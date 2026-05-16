import 'package:farmzy/core/network/api_client.dart';
import 'package:farmzy/features/market_rates/data/models/market_rate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final marketRatesRepositoryProvider = Provider<MarketRatesRepository>((ref) {
  final api = ref.read(apiClientProvider);
  return MarketRatesRepository(api);
});

class MarketRatesRepository {
  final ApiClient _api;

  MarketRatesRepository(this._api);

  Future<List<MarketRate>> getMarketRates({
    String? search,
    String? location,
    int page = 1,
    int limit = 10,
  }) async {
    final response = await _api.get(
      'market-rates',
      queryParameters: {
        if (search != null && search.isNotEmpty) 'commodity': search,
        if (location != null && location.isNotEmpty) 'district': location,
        'page': page,
        'limit': limit,
      },
    );

    final data = response.data['data'] as List<dynamic>? ?? [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(MarketRate.fromJson)
        .toList();
  }
}
