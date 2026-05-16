import 'package:farmzy/features/market_rates/data/market_rates_repository.dart';
import 'package:farmzy/features/market_rates/data/models/market_rate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final marketRatesSearchProvider = StateProvider<String>((ref) => '');
final marketRatesLocationProvider = StateProvider<String>((ref) => '');

class MarketRatesState {
  final List<MarketRate> rates;
  final bool isLoading;
  final bool hasMore;
  final int page;
  final String? error;

  const MarketRatesState({
    this.rates = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.page = 1,
    this.error,
  });

  MarketRatesState copyWith({
    List<MarketRate>? rates,
    bool? isLoading,
    bool? hasMore,
    int? page,
    String? error,
  }) {
    return MarketRatesState(
      rates: rates ?? this.rates,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      error: error,
    );
  }
}

class MarketRatesNotifier extends StateNotifier<MarketRatesState> {
  final MarketRatesRepository _repository;
  final Ref _ref;

  MarketRatesNotifier(this._repository, this._ref) : super(const MarketRatesState()) {
    // Initial fetch
    fetchNextPage();
    
    // Listen to search/location changes to reset pagination
    _ref.listen(marketRatesSearchProvider, (prev, next) {
      if (prev != next) refresh();
    });
    _ref.listen(marketRatesLocationProvider, (prev, next) {
      if (prev != next) refresh();
    });
  }

  Future<void> fetchNextPage() async {
    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoading: true);
    
    try {
      final search = _ref.read(marketRatesSearchProvider);
      final location = _ref.read(marketRatesLocationProvider);
      
      final newRates = await _repository.getMarketRates(
        search: search,
        location: location,
        page: state.page,
        limit: 15,
      );

      state = state.copyWith(
        rates: [...state.rates, ...newRates],
        isLoading: false,
        page: state.page + 1,
        hasMore: newRates.length >= 15,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    state = const MarketRatesState();
    await fetchNextPage();
  }
}

final marketRatesProvider = StateNotifierProvider<MarketRatesNotifier, MarketRatesState>((ref) {
  final repository = ref.watch(marketRatesRepositoryProvider);
  return MarketRatesNotifier(repository, ref);
});

final trendingRatesProvider = Provider<List<MarketRate>>((ref) {
  final allRates = ref.watch(marketRatesProvider).rates;
  return allRates.where((r) => r.demandLevel == 'HIGH').toList();
});

final priceGainersProvider = Provider<List<MarketRate>>((ref) {
  final allRates = ref.watch(marketRatesProvider).rates;
  return allRates.where((r) => r.trend == 'UP').toList();
});

final priceLosersProvider = Provider<List<MarketRate>>((ref) {
  final allRates = ref.watch(marketRatesProvider).rates;
  return allRates.where((r) => r.trend == 'DOWN').toList();
});
