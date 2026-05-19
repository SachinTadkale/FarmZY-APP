import 'dart:async';
import 'package:farmzy/core/constants/route_names.dart';
import 'package:farmzy/features/orders/presentation/widgets/order_card.dart';
import 'package:farmzy/features/orders/providers/orders_controller.dart';
import 'package:farmzy/shared/widgets/app_async_state.dart';
import 'package:farmzy/shared/widgets/app_scaffold.dart';
import 'package:farmzy/shared/widgets/app_shimmer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:farmzy/shared/widgets/premium_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:farmzy/shared/widgets/glass_container.dart';
import 'package:flutter_animate/flutter_animate.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  late final TextEditingController _searchController;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: ref.read(ordersSearchProvider),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();

    if (value.isEmpty) {
      ref.read(ordersSearchProvider.notifier).state = '';
      return;
    }

    if (value.length < 2) return;

    _debounce = Timer(const Duration(milliseconds: 350), () {
      ref.read(ordersSearchProvider.notifier).state = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedFilter = ref.watch(ordersFilterProvider);
    final ordersAsync = ref.watch(ordersProvider);
    final search = ref.watch(ordersSearchProvider);
    final theme = Theme.of(context);

    return AppScaffold(
      extendBodyBehindAppBar: true,
      body: Column(
        children: [
          _header(theme, selectedFilter),
          Expanded(
            child: ordersAsync.when(
              skipLoadingOnReload: true,
              data: (orders) {
                if (orders.isEmpty) {
                  return _emptyState(theme, search);
                }

                return RefreshIndicator(
                  edgeOffset: 120,
                  onRefresh: () async {
                    ref.read(ordersRefreshProvider.notifier).state++;
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return OrderCard(
                            order: order,
                            onTap: () {
                              if (order.id.isEmpty) return;
                              context.push('${RouteNames.orders}/${order.id}');
                            },
                          )
                          .animate()
                          .fadeIn(delay: (index * 100).ms)
                          .slideY(begin: 0.1, end: 0);
                    },
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    itemCount: orders.length,
                  ),
                );
              },
              loading: () => AppShimmer.list(
                height: 120,
                borderRadius: 28,
                padding: const EdgeInsets.all(20),
              ),
              error: (error, _) => AppErrorState(
                error: error,
                title: 'orders.error_load'.tr(),
                onRetry: () {
                  ref.read(ordersRefreshProvider.notifier).state++;
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(ThemeData theme, OrdersFilterTab selectedFilter) {
    return GlassContainer(
      borderRadius: 0,
      opacity: 0.05,
      blur: 20,
      border: Border.all(color: Colors.transparent, width: 0),
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 10,
        20,
        16,
      ),
      child: Column(
        children: [
          PremiumSearchBar(
            controller: _searchController,
            onChanged: _onSearchChanged,
            hintText: 'orders.search_hint'.tr(),
            suffix: _searchController.text.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      _searchController.clear();
                      _onSearchChanged('');
                    },
                    icon: const Icon(Icons.close_rounded, size: 20),
                  )
                : null,
          ),
          const SizedBox(height: 16),
          _OrdersFilterTabs(
            selectedFilter: selectedFilter,
            onChanged: (value) {
              ref.read(ordersFilterProvider.notifier).state = value;
            },
          ),
        ],
      ),
    );
  }

  Widget _emptyState(ThemeData theme, String search) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GlassContainer(
              borderRadius: 32,
              padding: const EdgeInsets.all(24),
              opacity: 0.05,
              blur: 10,
              child: Icon(
                Icons.inventory_2_outlined,
                size: 64,
                color: theme.colorScheme.primary.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              search.isEmpty
                  ? 'orders.no_orders'.tr()
                  : 'orders.no_orders_search'.tr(),
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn();
  }
}

class _OrdersFilterTabs extends StatelessWidget {
  final OrdersFilterTab selectedFilter;
  final ValueChanged<OrdersFilterTab> onChanged;

  const _OrdersFilterTabs({
    required this.selectedFilter,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _TabPill(
            title: 'orders.new'.tr(),
            isSelected: selectedFilter == OrdersFilterTab.newOrders,
            onTap: () => onChanged(OrdersFilterTab.newOrders),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _TabPill(
            title: 'orders.active'.tr(),
            isSelected: selectedFilter == OrdersFilterTab.active,
            onTap: () => onChanged(OrdersFilterTab.active),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _TabPill(
            title: 'orders.closed'.tr(),
            isSelected: selectedFilter == OrdersFilterTab.closed,
            onTap: () => onChanged(OrdersFilterTab.closed),
          ),
        ),
      ],
    );
  }
}

class _TabPill extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabPill({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedColor = theme.colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        borderRadius: 20,
        opacity: isSelected ? 0.2 : 0.05,
        blur: 0,
        color: isSelected ? selectedColor : Colors.grey,
        padding: const EdgeInsets.symmetric(vertical: 12),
        border: Border.all(
          color: isSelected
              ? selectedColor.withValues(alpha: 0.5)
              : Colors.transparent,
        ),
        child: Center(
          child: Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isSelected
                  ? selectedColor
                  : theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w900,
              fontSize: 13,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
