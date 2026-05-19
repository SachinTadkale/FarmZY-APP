import 'package:easy_localization/easy_localization.dart';
import 'package:farmzy/core/theme/app_spacing.dart';
import 'package:farmzy/features/market_rates/presentation/widgets/market_rate_card.dart';
import 'package:farmzy/features/market_rates/providers/market_rates_provider.dart';
import 'package:farmzy/features/profile/providers/profile_provider.dart';
import 'package:farmzy/shared/widgets/app_scaffold.dart';
import 'package:farmzy/shared/widgets/app_shimmer.dart';
import 'package:farmzy/shared/widgets/premium_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MarketRatesScreen extends ConsumerWidget {
  const MarketRatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppScaffold(
      appBar: AppBar(
        title: Text(
          'market_rates.title'.tr(),
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: const _MarketRatesBody(),
    );
  }
}

class _MarketRatesBody extends ConsumerStatefulWidget {
  const _MarketRatesBody();

  @override
  ConsumerState<_MarketRatesBody> createState() => _MarketRatesBodyState();
}

class _MarketRatesBodyState extends ConsumerState<_MarketRatesBody> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'ALL';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(marketRatesProvider.notifier).fetchNextPage();
    }
  }

  Widget _buildFilterChips(ThemeData theme) {
    final filters = [
      {'key': 'ALL', 'label': 'market_rates.all_markets'.tr(), 'icon': Icons.grid_view_rounded},
      {'key': 'TRENDING', 'label': 'market_rates.trending'.tr(), 'icon': Icons.bolt_rounded},
      {'key': 'GAINERS', 'label': 'market_rates.gainers'.tr(), 'icon': Icons.trending_up_rounded},
      {'key': 'LOSERS', 'label': 'market_rates.losers'.tr(), 'icon': Icons.trending_down_rounded},
      {'key': 'NEARBY', 'label': 'market_rates.nearby'.tr(), 'icon': Icons.location_on_rounded},
    ];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter['key'];
          final color = isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.05);
          final textColor = isSelected ? Colors.white : theme.colorScheme.onSurfaceVariant;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedFilter = filter['key'] as String;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? color : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? color : theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    filter['icon'] as IconData, 
                    size: 14, 
                    color: isSelected ? Colors.white : theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    filter['label'] as String,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(marketRatesProvider);
    final trending = ref.watch(trendingRatesProvider);
    final gainers = ref.watch(priceGainersProvider);
    final losers = ref.watch(priceLosersProvider);
    final profileAsync = ref.watch(profileProvider);

    final userDistrict = profileAsync.value?.location ?? '';
    List<dynamic> nearby = state.rates.where((r) {
      if (userDistrict.isEmpty) return false;
      return userDistrict.toLowerCase().contains(r.district.toLowerCase()) || 
             r.district.toLowerCase().contains(userDistrict.toLowerCase()) ||
             userDistrict.toLowerCase().contains(r.state.toLowerCase()) ||
             r.state.toLowerCase().contains(userDistrict.toLowerCase());
    }).toList();

    if (nearby.isEmpty) {
      nearby = state.rates.take(5).toList();
    }

    // Determine what to display in the main list
    final List<dynamic> displayRates;
    final bool showHorizontalSections;
    final String mainListTitle;
    final IconData mainListIcon;
    final Color? mainListIconColor;

    if (_selectedFilter == 'ALL') {
      displayRates = state.rates;
      showHorizontalSections = true;
      mainListTitle = 'market_rates.all_markets'.tr();
      mainListIcon = Icons.grid_view_rounded;
      mainListIconColor = null;
    } else if (_selectedFilter == 'TRENDING') {
      displayRates = trending;
      showHorizontalSections = false;
      mainListTitle = 'market_rates.trending'.tr();
      mainListIcon = Icons.bolt_rounded;
      mainListIconColor = Colors.orangeAccent;
    } else if (_selectedFilter == 'GAINERS') {
      displayRates = gainers;
      showHorizontalSections = false;
      mainListTitle = 'market_rates.gainers'.tr();
      mainListIcon = Icons.trending_up_rounded;
      mainListIconColor = Colors.greenAccent;
    } else if (_selectedFilter == 'LOSERS') {
      displayRates = losers;
      showHorizontalSections = false;
      mainListTitle = 'market_rates.losers'.tr();
      mainListIcon = Icons.trending_down_rounded;
      mainListIconColor = Colors.redAccent;
    } else {
      displayRates = nearby;
      showHorizontalSections = false;
      mainListTitle = 'market_rates.nearby'.tr();
      mainListIcon = Icons.location_on_rounded;
      mainListIconColor = Colors.blueAccent;
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(marketRatesProvider.notifier).refresh(),
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PremiumSearchBar(
                    controller: _searchController,
                    hintText: 'market_rates.search_hint'.tr(),
                    onChanged: (v) =>
                        ref.read(marketRatesSearchProvider.notifier).state =
                            v,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildFilterChips(theme),
                  const SizedBox(height: AppSpacing.lg),

                  if (showHorizontalSections) ...[
                    if (trending.isNotEmpty) ...[
                      _SectionHeader(
                        title: 'market_rates.trending'.tr(),
                        icon: Icons.bolt_rounded,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _HorizontalRatesList(rates: trending),
                      const SizedBox(height: AppSpacing.xl),
                    ],

                    if (gainers.isNotEmpty) ...[
                      _SectionHeader(
                        title: 'market_rates.gainers'.tr(),
                        icon: Icons.trending_up_rounded,
                        color: Colors.greenAccent,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _HorizontalRatesList(rates: gainers),
                      const SizedBox(height: AppSpacing.xl),
                    ],

                    if (losers.isNotEmpty) ...[
                      _SectionHeader(
                        title: 'market_rates.losers'.tr(),
                        icon: Icons.trending_down_rounded,
                        color: Colors.redAccent,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _HorizontalRatesList(rates: losers),
                      const SizedBox(height: AppSpacing.xl),
                    ],
                  ],

                  _SectionHeader(
                    title: mainListTitle,
                    icon: mainListIcon,
                    color: mainListIconColor,
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
          ),
          
          if (displayRates.isEmpty && state.isLoading)
            const SliverFillRemaining(
              child: _LoadingSkeleton(),
            )
          else if (displayRates.isEmpty && !state.isLoading)
            SliverFillRemaining(
              child: Center(
                child: Text('market_rates.no_data'.tr()),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index >= displayRates.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: MarketRateCard(rate: displayRates[index]),
                    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0);
                  },
                  childCount: displayRates.length + (_selectedFilter == 'ALL' && state.hasMore ? 1 : 0),
                ),
              ),
            ),
          
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color? color;

  const _SectionHeader({required this.title, required this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: color ?? theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}

class _HorizontalRatesList extends StatelessWidget {
  final List<dynamic> rates;

  const _HorizontalRatesList({required this.rates});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: rates.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, index) =>
            SizedBox(width: 300, child: MarketRateCard(rate: rates[index])),
      ),
    );
  }
}

class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppShimmer.rectangular(
            height: 56,
            shapeBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const AppShimmer.rectangular(height: 24, width: 150),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: List.generate(
              2,
              (index) => const Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: AppShimmer.rectangular(
                    height: 160,
                    shapeBorder: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(24)),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const AppShimmer.rectangular(height: 24, width: 150),
          const SizedBox(height: AppSpacing.md),
          ...List.generate(
            3,
            (index) => const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: AppShimmer.rectangular(
                height: 100,
                shapeBorder: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(24)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
